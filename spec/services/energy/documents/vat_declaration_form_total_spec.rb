require "rails_helper"

RSpec.describe Energy::Documents::VatDeclarationFormTotal, type: :model do
  subject(:service) { described_class.new(onboarding_case:, flatten:) }

  let(:support_organisation) { create(:support_organisation) }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:flatten) { false }
  let(:onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation, **input_values) }
  let(:meter_type) { :single }

  describe "#call" do
    let(:input_values) do
      {
        vat_rate: 5,
        vat_lower_rate_percentage: 12,
        vat_lower_rate_reg_no: "GB123456789",
        vat_person_correct_details: true,
        vat_person_first_name: "John",
        vat_person_last_name: "Doe",
        gas_single_multi: meter_type,
        vat_person_address: {
          street: "456 Secondary St",
          locality: "Suite 5",
          town: "Another City",
          postcode: "67890",
        },
      }
    end

    context "with vat person details" do
      let(:energy_gas_meter) { create(:energy_gas_meter, :with_valid_data, onboarding_case_organisation:) }

      before do
        energy_gas_meter
        service.call
      end

      it "creates new pdf file" do
        expect(File.exist?(service.output_pdf_file)).to be true
      end

      it "matches the input values with the output pdf" do
        fields = service.pdftk.get_fields(service.output_pdf_file)
        values = fields.map(&:value).compact

        expect(values).to include("#{input_values[:vat_lower_rate_percentage]}%")
        expect(values).to include(input_values[:vat_lower_rate_reg_no])
        expect(values).to include("#{input_values[:vat_person_first_name]} #{input_values[:vat_person_last_name]}")
        expect(values).to include(input_values[:vat_person_address][:street])
        expect(values).to include(input_values[:vat_person_address][:locality])
        expect(values).to include(input_values[:vat_person_address][:town])
        expect(values).to include(input_values[:vat_person_address][:postcode])
        expect(values).to include("Gas")
        expect(values).to include(energy_gas_meter.mprn)
      end
    end

    context "with multiple mprn numbers" do
      let(:meter_type) { :multi }
      let(:gas_meter1) { create(:energy_gas_meter, mprn: 123_456_789, gas_usage: 1000, onboarding_case_organisation:) }
      let(:gas_meter2) { create(:energy_gas_meter, mprn: 223_456_987, gas_usage: 2000, onboarding_case_organisation:) }

      before do
        gas_meter1
        gas_meter2
        service.call
      end

      it "includes all mprn numbers (multi)" do
        fields = service.pdftk.get_fields(service.output_pdf_file)
        values = fields.map(&:value).compact

        expect(values).to include(gas_meter1.mprn)
        expect(values).to include(gas_meter2.mprn)
      end
    end

    context "with vat alternate person details" do
      let(:input_values) do
        {
          vat_rate: 5,
          vat_lower_rate_percentage: 12,
          vat_lower_rate_reg_no: "GB123456789",
          vat_person_correct_details: false,
          vat_alt_person_first_name: "John",
          vat_alt_person_last_name: "Doe",
          vat_alt_person_address: {
            street: "292 Some road",
            locality: "Suite 9",
            town: "New City",
            postcode: "WD18 0FV",
          },
        }
      end

      before do
        onboarding_case_organisation
        service.call
      end

      it "creates new pdf file" do
        expect(File.exist?(service.output_pdf_file)).to be true
      end

      it "matches the input values with the output pdf" do
        fields = service.pdftk.get_fields(service.output_pdf_file)
        values = fields.map(&:value).compact

        expect(values).to include("#{input_values[:vat_alt_person_first_name]} #{input_values[:vat_alt_person_last_name]}")
        expect(values).to include(input_values[:vat_alt_person_address][:street])
        expect(values).to include(input_values[:vat_alt_person_address][:locality])
        expect(values).to include(input_values[:vat_alt_person_address][:town])
        expect(values).to include(input_values[:vat_alt_person_address][:postcode])
      end
    end

    context "with flattened fields" do
      let(:flatten) { true }

      before do
        onboarding_case_organisation
        service.call
      end

      it "creates new pdf file" do
        expect(File.exist?(service.output_pdf_file)).to be true
      end

      it "fields are flattened" do
        fields = service.pdftk.get_fields(service.output_pdf_file)
        expect(fields.all?(&:flattened?)).to be true
      end
    end
  end
end
