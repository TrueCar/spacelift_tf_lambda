# frozen_string_literal: true

require 'aws-sdk-core'
require_relative './region_resolver'
require_relative './account_config'

# Configures AWS credentials for Ops roles
# using ops admin accounts json in Secrets Manager

module AwsSupport
  class OpsCredentialResolver
    class << self
      def resolve(purpose:, settings:, sts_client: nil, duration: nil, policy: nil)
        if settings['account_id']
          found_config = AccountConfig.config_for_account_id(settings['account_id'], purpose)
        elsif settings['account_name']
          found_config = AccountConfig.config_for_account_name(settings['account_name'], purpose)
        else
          raise 'account_id or account_name required, string'
        end

        return nil unless found_config

        if sts_client
          found_config['client'] = sts_client
        else
          # by default, AWS SDK uses credentials from global endpoint (sts.amazonaws.com) in IAD.
          # force calls to use regional endpoint
          # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_enable-regions.html#sts-regions-manage-tokens
          found_config['client'] = Aws::STS::Client.new(
            region: RegionResolver.resolve,
            # https://github.com/aws/aws-sdk-ruby/pull/2090
            sts_regional_endpoints: 'regional'
          )
        end

        # extra config for duration and policy if necessary

        raise 'duration must be integer' if
          duration && !duration.is_a?(Integer)

        raise 'policy must be string' if
          policy && !policy.is_a?(String)

        assume_role_credentials_for_config(
          found_config, duration: duration, policy: policy)
      end

      def assume_role_credentials_for_config(config, duration: nil, policy: nil)
        raise "role_arn missing for #{config.inspect}" if
          config['role_arn'].nil?

        role_arn = config['role_arn']

        # new credentials
        assume_cred_args = {
          client: config['client'],
          role_arn: role_arn,
          role_session_name: 'assume_role_for_account'
        }
        assume_cred_args[:external_id] = config['external_id'] if
          config['external_id']
        assume_cred_args[:duration_seconds] = duration if duration
        assume_cred_args[:policy] = policy if policy

        Aws::AssumeRoleCredentials.new(assume_cred_args)
      end
    end
  end
end
