require "rails_helper"

RSpec.describe Energy::OnboardingCaseOrganisation, type: :model do
  describe "enums" do
    it "defines gas_current_supplier enum with correct values" do
      expect(described_class.gas_current_suppliers).to eq(
        "british_gas" => 0,
        "edf_energy" => 1,
        "eon_next" => 2,
        "scotish_power" => 3,
        "ovo_energy" => 4,
        "octopus_energy" => 5,
        "other" => 6,
      )
    end

    it "defines electric_current_supplier enum with correct values" do
      expect(described_class.electric_current_suppliers).to eq(
        "british_gas" => 0,
        "edf_energy" => 1,
        "eon_next" => 2,
        "scotish_power" => 3,
        "ovo_energy" => 4,
        "octopus_energy" => 5,
        "other" => 6,
      )
    end
  end
end
