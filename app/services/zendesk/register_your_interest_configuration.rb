# frozen_string_literal: true

module Zendesk
  class RegisterYourInterestConfiguration
    class ConfigurationError < StandardError; end

    STAGING_TICKET_FORM_ID = 35_484_269_639_570
    STAGING_FIELD_IDS = {
      contact_number: 34_677_379_305_490,
      electricity_contract_end_date: 34_677_517_704_082,
      gas_contract_end_date: 34_677_545_715_218,
      switch_gas: 35_483_951_884_690,
      switch_electricity: 35_484_030_231_314,
      ukprn: 35_484_141_965_458,
      mat_name: 37_977_986_359_570,
    }.freeze

    PRODUCTION_TICKET_FORM_ID = nil
    PRODUCTION_FIELD_IDS = {
      contact_number: nil,
      electricity_contract_end_date: nil,
      gas_contract_end_date: nil,
      switch_gas: nil,
      switch_electricity: nil,
      ukprn: nil,
      mat_name: nil,
    }.freeze

    FORM_IDS_BY_ENVIRONMENT = {
      "staging" => { ticket_form_id: STAGING_TICKET_FORM_ID, field_ids: STAGING_FIELD_IDS }.freeze,
      "production" => { ticket_form_id: PRODUCTION_TICKET_FORM_ID, field_ids: PRODUCTION_FIELD_IDS }.freeze,
    }.freeze

    def self.current
      for_environment(ENV.fetch("ZENDESK_ENVIRONMENT", "staging"))
    end

    def self.for_environment(environment)
      configuration = FORM_IDS_BY_ENVIRONMENT[environment]
      raise ConfigurationError, "ZENDESK_ENVIRONMENT must be 'staging' or 'production'" unless configuration

      missing_ids = [:ticket_form_id, *configuration[:field_ids].keys].select do |key|
        value = key == :ticket_form_id ? configuration[:ticket_form_id] : configuration[:field_ids][key]
        value.blank?
      end
      if missing_ids.any?
        raise ConfigurationError, "Zendesk RYI IDs are not configured for #{environment}: #{missing_ids.join(', ')}"
      end

      configuration
    end

    private_class_method :for_environment
  end
end
