require "rails_helper"

RSpec.describe Energy::RegisterYourInterestGasForm do
  describe "validation" do
    it "requires a switch choice" do
      form = described_class.new

      expect(form).not_to be_valid
      expect(form.errors.messages[:switch_gas]).to eq([I18n.t("energy.register_your_interests.gas.index.gas.switch_error")])
    end

    it "allows an omitted date when switching gas" do
      form = described_class.new(switch_gas: true)

      expect(form).to be_valid
      expect(form.registration_attributes).to eq(switch_gas: true, gas_contract_end_date: nil)
    end

    it "rejects an invalid date when switching gas" do
      form = described_class.new(switch_gas: true)
      form.instance_variable_set(:@gas_contract_end_date, { 1 => "2027", 2 => "2", 3 => "30" })

      expect(form).not_to be_valid
      expect(form.errors.messages[:gas_contract_end_date]).to eq([I18n.t("energy.register_your_interests.gas.index.gas.invalid_date")])
    end

    it "rejects a date outside the allowed range" do
      form = described_class.new(switch_gas: true, gas_contract_end_date: Date.current.advance(years: -6))

      expect(form).not_to be_valid
      expect(form.errors.messages[:gas_contract_end_date]).to eq([I18n.t("energy.register_your_interests.gas.index.gas.out_of_range")])
    end
  end

  describe "#registration_attributes" do
    it "returns the selected answer and date" do
      date = Date.new(2027, 8, 1)
      form = described_class.new(switch_gas: true, gas_contract_end_date: date)

      expect(form.registration_attributes).to eq(switch_gas: true, gas_contract_end_date: date)
    end

    it "clears the date when the user does not want to switch" do
      form = described_class.new(switch_gas: false, gas_contract_end_date: Date.new(2027, 8, 1))

      expect(form.registration_attributes).to eq(switch_gas: false, gas_contract_end_date: nil)
    end
  end
end
