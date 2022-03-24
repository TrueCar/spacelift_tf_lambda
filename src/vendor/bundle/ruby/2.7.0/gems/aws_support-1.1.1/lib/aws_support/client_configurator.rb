# frozen_string_literal: true

require 'aws-sdk-core'

require_relative './credential_resolver'
require_relative './ops_credential_resolver'

# Automatically configures AWS credentials based on prefixed environment variables or Settings keys
#
# Preference:
# 1. IAM role (with optional 3rd party)
# 2. IAM user access keys
# 3. Fallback to default credentials (default)
#
# Client region configured based on:
# 1. Passed region
# 2. {purpose}_REGION settings/ENV key
# 3. Resolved region (ENV, ECS/EC2)
module AwsSupport
  class ClientConfigurator
    class << self
      # XXX: access_key and secret_key are deprecated, only here for transitional purposes.
      def configure(purpose: nil, region: nil, profile: nil, settings: nil, sts_client: nil, access_key: nil, secret_key: nil, duration: nil, policy: nil)
        client_args = {}

        configure_client_region(client_args, region: region, purpose: purpose, settings: settings)

        case purpose
        when nil
          rslvr_creds = nil
        when 'admin', 'deployer'
          rslvr_creds = OpsCredentialResolver.resolve(purpose: purpose, settings: settings, sts_client: sts_client, duration: nil, policy: nil)
        else
          rslvr_creds = CredentialResolver.resolve(purpose: purpose, settings: settings, sts_client: sts_client, duration: nil)
        end

        if rslvr_creds
          client_args[:credentials] = rslvr_creds
          return client_args
        end

        if profile && detect_mastermind1_profile(profile)
          # we configure :profile on client directly because the credential chain has separate entries
          # for the various methods of configuring the client:
          # https://github.com/aws/aws-sdk-ruby/blob/a8332558e8c8a4889dfce17dd54742172500dffb/gems/aws-sdk-core/lib/aws-sdk-core/credential_provider_chain.rb#L25
          #
          # if a SharedConfig has anything other than access keys, passing it as credentials like:
          #   credentials: Aws::SharedCredentials.new(...)
          # fails to resolve the credentials
          client_args[:profile] = profile
          return client_args
        end

        # XXX: access_key and secret_key are deprecated
        # explicit access keys are preferred LAST, except over the default credentials
        if access_key && secret_key
          client_args[:credentials] = Aws::Credentials.new(access_key, secret_key)
          return client_args
        end

        # just default
        client_args
      end

      protected

      def configure_client_region(client_options, region: nil, purpose: nil, settings:)
        if region
          client_options[:region] = region
          return
        end

        # fallback to purpose/settings
        if purpose
          settings ||= ENV
          conf_region = settings["#{purpose}_REGION"]
          if conf_region
            client_options[:region] = conf_region if conf_region
            return
          end
        end

        # running (or configured) region
        rslv_region = RegionResolver.resolve
        client_options[:region] = rslv_region if rslv_region
      end

      # legacy MM1 support: profile is not always present if app is not configured for mm1,
      # will need to fall back to other methods
      #
      # only detect if a role with that name is configured. if so, must specify :profile
      # to client creation to utilize default credential chain
      # https://github.com/aws/aws-sdk-ruby/blob/a8332558e8c8a4889dfce17dd54742172500dffb/gems/aws-sdk-core/lib/aws-sdk-core/credential_provider_chain.rb#L151
      def detect_mastermind1_profile(profile)
        begin
          Aws::SharedCredentials.new(profile_name: profile)
          true
        rescue Aws::Errors::NoSuchProfileError
          false
        end
      end
    end
  end
end
