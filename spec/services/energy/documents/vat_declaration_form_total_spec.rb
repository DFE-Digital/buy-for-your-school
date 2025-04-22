require "rails_helper"

RSpec.describe Energy::Documents::VatDeclarationFormTotal, type: :model do
  subject(:service) { described_class.new(onboarding_case) }

  let(:support_organisation) { create(:support_organisation) }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation, **input_values) }

  describe "#call" do
    context "with vat person details" do
      let(:input_values) do
        {
          vat_rate: 5,
          vat_lower_rate_percentage: 12,
          vat_lower_rate_reg_no: "GB123456789",
          vat_person_correct_details: true,
          vat_person_first_name: "John",
          vat_person_last_name: "Doe",
          vat_person_address: {
            street: "456 Secondary St",
            locality: "Suite 5",
            town: "Another City",
            postcode: "67890",
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

        expect(values).to include("#{input_values[:vat_lower_rate_percentage]}%")
        expect(values).to include(input_values[:vat_lower_rate_reg_no])
        expect(values).to include("#{input_values[:vat_person_first_name]} #{input_values[:vat_person_last_name]}")
        expect(values).to include(input_values[:vat_person_address][:street])
        expect(values).to include(input_values[:vat_person_address][:locality])
        expect(values).to include(input_values[:vat_person_address][:town])
        expect(values).to include(input_values[:vat_person_address][:postcode])
        expect(values).to include("Gas")
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
  end
end
