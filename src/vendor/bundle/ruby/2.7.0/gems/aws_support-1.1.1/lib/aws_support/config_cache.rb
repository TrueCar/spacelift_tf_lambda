# frozen_string_literal: true

require 'aws-sdk-secretsmanager'
require 'json'

module AwsSupport
  class ConfigCache
    @loaded_config = {}
    HOUR_IN_SECONDS = 60 * 60

    class << self
      def fetch_secrets_manager_config(config_name)
        cached_config(config_name) do
          resp = secrets_manager_client.get_secret_value(secret_id: config_name)
          secret_string = resp['secret_string']
          raise "Secret <#{config_name}> expected but was empty" if
            secret_string.nil? || secret_string.empty?

          JSON.parse(secret_string)
        end
      end

      def cached_config(cache_key)
        found_cache = @loaded_config[cache_key]
        if found_cache
          if found_cache[:expires] > Time.now.to_i
            return found_cache[:value]
          else
            @loaded_config.delete(cache_key)
          end
        end

        raise 'block required' unless block_given?

        result = yield

        if result
          @loaded_config[cache_key] = {
            value: result,
            expires: Time.now.to_i + HOUR_IN_SECONDS
          }
        end

        result
      end

      def secrets_manager_client
        @secrets_manager_client ||= Aws::SecretsManager::Client.new()
      end
    end
  end
end
