require "rails_helper"

RSpec.describe Energy::ElectricityMeter, type: :model do
  let(:support_case) { create(:support_case) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:) }
  let(:electricity_meter) { create(:energy_electricity_meter, :with_valid_data, onboarding_case_organisation:) }

  it "updates the updated_at timestamp in Support::Case when ElectricityMeter is updated" do
    initial_timestamp = support_case.updated_at

    electricity_meter.update!(mpan: "1234567890123")

    support_case.reload

    expect(support_case.updated_at).to be > initial_timestamp
  end

  describe "electricity_usage" do
    subject(:meter) { build(:energy_electricity_meter, :with_valid_data, onboarding_case_organisation:) }

    let(:message) { "Estimated annual usage in kilowatt hours must be a number between 1 and 1,000,000. For example, 93,800" }

    it "accepts numbers with commas and stores them without commas" do
      meter.electricity_usage = "93,800"

      expect(meter).to be_valid
      expect(meter.electricity_usage).to eq("93800")
    end

    it "accepts numbers with spaces" do
      meter.electricity_usage = "93 800"

      expect(meter).to be_valid
      expect(meter.electricity_usage).to eq("93800")
    end

    it "accepts 1,000,000" do
      meter.electricity_usage = "1,000,000"

      expect(meter).to be_valid
    end

    it "accepts 1" do
      meter.electricity_usage = "1"

      expect(meter).to be_valid
    end

    it "rejects 0" do
      meter.electricity_usage = "0"

      expect(meter).not_to be_valid
      expect(meter.errors[:electricity_usage]).to include(message)
    end

    it "rejects numbers over 1,000,000" do
      meter.electricity_usage = "1,000,001"

      expect(meter).not_to be_valid
      expect(meter.errors[:electricity_usage]).to include(message)
    end

    it "rejects non-numeric values" do
      meter.electricity_usage = "abc"

      expect(meter).not_to be_valid
      expect(meter.errors[:electricity_usage]).to include(message)
    end
  end

  describe "supply_capacity" do
    it "accepts numbers with commas and stores them without commas" do
      meter = build(:energy_electricity_meter, :with_valid_data, onboarding_case_organisation:, is_half_hourly: true,
                                                                 data_aggregator: "Agg", data_collector: "Col", meter_operator: "Op")
      meter.supply_capacity = "1,500"

      expect(meter).to be_valid
      expect(meter.supply_capacity).to eq("1500")
    end
  end
end
