require "rails_helper"

RSpec.describe Energy::GasMeter, type: :model do
  let(:support_case) { create(:support_case) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:) }
  let(:gas_meter) { create(:energy_gas_meter, :with_valid_data, onboarding_case_organisation:) }

  it "updates the updated_at timestamp in Support::Case when GasMeter is updated" do
    initial_timestamp = support_case.updated_at

    gas_meter.update!(mprn: "5555555555")

    support_case.reload

    expect(support_case.updated_at).to be > initial_timestamp
  end

  describe "gas_usage" do
    subject(:meter) { build(:energy_gas_meter, :with_valid_data, onboarding_case_organisation:) }

    let(:message) { "Estimated annual usage in kilowatt hours must be a number between 1 and 1,000,000. For example, 93,800" }

    it "accepts numbers with commas and stores them without commas" do
      meter.gas_usage = "93,800"

      expect(meter).to be_valid
      expect(meter.gas_usage).to eq("93800")
    end

    it "accepts numbers with spaces" do
      meter.gas_usage = "93 800"

      expect(meter).to be_valid
      expect(meter.gas_usage).to eq("93800")
    end

    it "accepts 1,000,000" do
      meter.gas_usage = "1,000,000"

      expect(meter).to be_valid
    end

    it "accepts 1" do
      meter.gas_usage = "1"

      expect(meter).to be_valid
    end

    it "rejects 0" do
      meter.gas_usage = "0"

      expect(meter).not_to be_valid
      expect(meter.errors[:gas_usage]).to include(message)
    end

    it "rejects numbers over 1,000,000" do
      meter.gas_usage = "1,000,001"

      expect(meter).not_to be_valid
      expect(meter.errors[:gas_usage]).to include(message)
    end

    it "rejects non-numeric values" do
      meter.gas_usage = "abc"

      expect(meter).not_to be_valid
      expect(meter.errors[:gas_usage]).to include(message)
    end
  end
end
