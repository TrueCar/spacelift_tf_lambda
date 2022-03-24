# frozen_string_literal: true

require_relative './config_cache'

module AwsSupport
  class AccountConfig
    SM_ACCOUNTS_ADMIN = 'infra/ops-admin-accounts-json'
    SM_ACCOUNTS_READONLY = 'infra/ops-readonly-accounts-json'

    SM_ACCOUNTS_OPTION_TO_KEY = {
      admin: SM_ACCOUNTS_ADMIN,
      readonly: SM_ACCOUNTS_READONLY
    }.freeze

    class << self
      def config_for_account_id(account_id, purpose)
        all_acct = fetch_account_role_config(purpose)
        all_acct.select { |acct| acct['account_id'] == account_id }.first
      end

      def config_for_account_name(account_name, purpose)
        all_acct = fetch_account_role_config(purpose)
        all_acct.select { |acct| acct['name'] == account_name }.first
      end

      def account_role_config_key(purpose)
        if SM_ACCOUNTS_OPTION_TO_KEY.has_key?(purpose.to_sym)
          fetch_key = SM_ACCOUNTS_OPTION_TO_KEY[purpose.to_sym]
        else
          raise "unsupported config_type: #{purpose}"
        end
        fetch_key
      end

      def fetch_account_role_config(purpose)
        fetch_key = account_role_config_key(purpose)
        ConfigCache.fetch_secrets_manager_config(fetch_key)
      end
    end
  end
end
