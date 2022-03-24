# frozen_string_literal: true

require 'aws-sdk-core'

require_relative './region_resolver'

# Automatically configures AWS credentials based on prefixed environment variables or Settings keys
#
# Preference:
# 1. IAM role (with optional 3rd party)
# 2. IAM user access keys
# 3. Fallback to default credentials (default)
module AwsSupport
  class CredentialResolver
    class << self
      def resolve(purpose:, settings: nil, sts_client: nil, duration: nil)
        # fallback to environment
        settings ||= ENV

        if (role_arn = settings["#{purpose}_ROLE_ARN"])
          assume_args = {
            role_arn: role_arn,
            role_session_name: assume_role_session_name(purpose)
          }

          if sts_client
            assume_args[:client] = sts_client
          else
            # by default, AWS SDK uses credentials from global endpoint (sts.amazonaws.com) in IAD.
            # force calls to use regional endpoint
            # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_enable-regions.html#sts-regions-manage-tokens
            assume_args[:client] = Aws::STS::Client.new(
              region: RegionResolver.resolve,
              # https://github.com/aws/aws-sdk-ruby/pull/2090
              sts_regional_endpoints: 'regional'
            )
          end

          # https://aws.amazon.com/blogs/security/how-to-use-external-id-when-granting-access-to-your-aws-resources/
          if (external_id = settings["#{purpose}_EXTERNAL_ID"])
            assume_args[:external_id] = external_id
          end

          if (duration_str = settings["#{purpose}_ROLE_DURATION"])
            dur = Integer(duration_str) rescue nil
            if dur
              assume_args[:duration_seconds] = dur
            end
          elsif duration
            assume_args[:duration_seconds] = duration
          end

          Aws::AssumeRoleCredentials.new(assume_args)
        elsif (access_key = settings["#{purpose}_ACCESS_KEY"])
          # multiple variations of secret key used
          secret_key = settings["#{purpose}_SECRET_KEY"]
          secret_key ||= settings["#{purpose}_SECRET_ACCESS_KEY"]

          if secret_key
            Aws::Credentials.new(access_key, secret_key)
          end
        end
      end

      def assume_role_session_name(purpose)
        # use build number if deployed
        # allowed chars https://docs.aws.amazon.com/cli/latest/reference/sts/assume-role.html
        build_num = ENV['BUILD_NUMBER']
        build_num_str = build_num ? "@#{build_num}" : ''
        "#{application_name}#{build_num_str} #{purpose}".gsub(/[^a-zA-Z0-9=,\.@\-]/, '-')[0...64]
      end

      # e.g. AbpBackend -> abp-backend
      def application_name
        if defined?(Rails)
          # Rails 6+ renamed it to module_parent_name
          if Rails::VERSION::MAJOR >= 6
            @app_name ||= Rails.application.class.module_parent_name.titleize.parameterize
          else
            @app_name ||= Rails.application.class.parent_name.titleize.parameterize
          end
        else
          @app_name ||= 'truecar'
        end
      end

      def application_name=(val)
        @app_name = val
      end
    end
  end
end
