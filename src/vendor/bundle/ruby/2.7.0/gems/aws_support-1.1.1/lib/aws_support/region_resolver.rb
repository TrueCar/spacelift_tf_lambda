# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

# Automatically figures out the AWS region where we are running
#
# Preference:
# 1. ECS metadata
# 2. EC2 metdata
# 3. AWS_REGION environment
# 4. us-west-2
module AwsSupport
  class RegionResolver
    class << self
      DEFAULT_AWS_REGION = 'us-west-2'

      REGION_REGEX = /^([a-z]+-[a-z]+-\d)(?:[a-z]|-)/

      ECS_METADATA_HOST = '169.254.170.2'

      EC2_IMDS_TOKEN_URI = URI.parse('http://169.254.169.254/latest/api/token')
      EC2_IDMS_TOKEN_TTL_HEADER = 'X-aws-ec2-metadata-token-ttl-seconds'
      EC2_IDMS_TOKEN_TTL = (30 * 60).freeze
      EC2_IDMS_TOKEN_HEADER = 'X-aws-ec2-metadata-token'
      EC2_IMDS_URI_STR = 'http://169.254.169.254/latest/meta-data'
      EC2_IMDS_AZ_URI = URI.parse("#{EC2_IMDS_URI_STR}/placement/availability-zone")

      def resolve
        @the_region ||= resolver_chain
      end

      private

      def resolver_chain
        if probably_in_aws?
          from_ecs_metadata || from_ec2_metadata || ENV['AWS_REGION'] || DEFAULT_AWS_REGION
        else
          ENV['AWS_REGION'] || DEFAULT_AWS_REGION
        end
      end

      # XXX: is there a better way to determine this?
      def probably_in_aws?
        ENV.key?('SPACEPODS_ENV')
      end

      def region_from_az(az)
        # formats: us-west-2a or us-west-2-lax-1a
        if (match = REGION_REGEX.match(az))
          match[1]
        end
      end

      def from_ecs_metadata
        az = ecs_metadata_aws_az
        az ? region_from_az(az) : nil
      end

      # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html
      def ecs_metadata_aws_az
        if ENV.key?('ECS_CONTAINER_METADATA_URI')
          uri_str = "#{ENV['ECS_CONTAINER_METADATA_URI']}/task"
          uri = URI.parse(uri_str)

          # make sure we are using the known metadata host
          return nil if uri.host != ECS_METADATA_HOST

          Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
            req = Net::HTTP::Get.new(uri)
            resp = http.request(req)
            raise unless resp.code == '200'
            body = JSON.parse(resp.body)
            return body['AvailabilityZone']
          end
        end

        nil
      rescue
        puts "#{$!.class.name}: #{$!.message}"
        puts $!.backtrace.join("\n")

        nil
      end

      def from_ec2_metadata
        az = ec2_metadata_aws_az
        az ? region_from_az(az) : nil
      end

      # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html
      def ec2_metadata_aws_az
        # sanity check, token and metadata uri should be the same host
        raise 'host mismatch' unless EC2_IMDS_TOKEN_URI.host == EC2_IMDS_AZ_URI.host

        Net::HTTP.start(EC2_IMDS_AZ_URI.host, EC2_IMDS_AZ_URI.port, use_ssl: EC2_IMDS_AZ_URI.scheme == 'https') do |http|
          # get token
          token_req = Net::HTTP::Put.new(EC2_IMDS_TOKEN_URI)
          token_req[EC2_IDMS_TOKEN_TTL_HEADER] = EC2_IDMS_TOKEN_TTL
          token_resp = http.request(token_req)
          raise unless token_resp.code == '200'
          token = token_resp.body
          puts token.inspect

          md_req = Net::HTTP::Get.new(EC2_IMDS_AZ_URI)
          md_req[EC2_IDMS_TOKEN_HEADER] = token
          md_resp = http.request(md_req)
          raise unless md_resp.code == '200'
          az = md_resp.body
          return az
        end

        raise
      end
    end
  end
end
