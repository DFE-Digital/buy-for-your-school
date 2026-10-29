require "rails_helper"

RSpec.describe Zendesk::RegisterYourInterestConfiguration do
  describe ".current" do
    it "defaults to the staging form IDs when the environment is not set" do
      ClimateControl.modify(ZENDESK_ENVIRONMENT: nil) do
        configuration = described_class.current

        expect(configuration[:ticket_form_id]).to eq(35_484_269_639_570)
        expect(configuration[:field_ids]).to eq(
          contact_number: 34_677_379_305_490,
          electricity_contract_end_date: 34_677_517_704_082,
          gas_contract_end_date: 34_677_545_715_218,
          switch_gas: 35_483_951_884_690,
          switch_electricity: 35_484_030_231_314,
          ukprn: 35_484_141_965_458,
          mat_name: 37_977_986_359_570,
        )
      end
    end

    it "raises a clear error when production IDs have not been configured" do
      ClimateControl.modify(ZENDESK_ENVIRONMENT: "production") do
        expect { described_class.current }
          .to raise_error(described_class::ConfigurationError, /Zendesk RYI IDs are not configured for production/)
      end
    end

    it "rejects an unsupported environment" do
      ClimateControl.modify(ZENDESK_ENVIRONMENT: "development") do
        expect { described_class.current }
          .to raise_error(described_class::ConfigurationError, /must be 'staging' or 'production'/)
      end
    end
  end
end
