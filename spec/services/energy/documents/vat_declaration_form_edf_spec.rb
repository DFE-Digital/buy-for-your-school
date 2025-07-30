require "rails_helper"

RSpec.describe Energy::Documents::VatDeclarationFormEdf, type: :model do
  subject(:service) { described_class.new(onboarding_case:, flatten:) }

  let(:support_organisation) { create(:support_organisation, name: "Hillside School") }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:flatten) { false }
  let(:onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation, **input_values) }
  let(:energy_electricity_meter) { create(:energy_electricity_meter, :with_valid_data, onboarding_case_organisation:) }

  let(:fields) { service.pdftk.get_fields(service.output_pdf_file) }
  let(:values) { fields.map(&:value).compact }
  let(:county) { "Hertfordshire" }

  describe "#call" do
    let(:input_values) do
      {
        vat_rate: 5,
        electric_current_contract_end_date: Date.new(2025, 12, 12),
        vat_lower_rate_reg_no: "123456789",
        vat_person_correct_details: true,
        vat_person_first_name: "John",
        vat_person_last_name: "Doe",
        vat_person_phone: "01234567890",
        vat_person_address: {
          street: "456 Secondary St",
          locality: "Suite 5",
          town: "Another City",
          county:,
          postcode: "WD18 0FV",
        },
      }
    end

    context "with vat person details" do
      before do
        energy_electricity_meter
        service.call
      end

      it "creates new pdf file" do
        expect(File.exist?(service.output_pdf_file)).to be true
      end

      it "matches the input values with the output pdf" do
        expect(values).to include(Energy::Documents::VatDeclarationFormEdf::BUSINESS_NAME)
        expect(values).to include(support_organisation.name)

        expect(fields.find { |f| f.name == "ELECTRCITY" }.value).to eq "Yes"
        expect(fields.find { |f| f.name == "CHARITY" }.value).to eq "Yes"
        full_name = fields.find { |f| f.name == "FULL NAME" }.value
        expect(full_name).to eq("#{input_values[:vat_person_first_name]} #{input_values[:vat_person_last_name]}".upcase)
        expect(fields.find { |f| f.name == "TELEPHONE" }.value).to eq input_values[:vat_person_phone]
      end

      context "with address fields" do
        it "joins locality and town in address line 3" do
          address_line3 = "#{input_values[:vat_person_address][:locality]}, #{input_values[:vat_person_address][:town]}".strip
          expect(fields.find { |f| f.name == "ADDRESS 3" }.value).to eq(address_line3)
        end

        it "populates county" do
          expect(fields.find { |f| f.name == "ADDRESS 4" }.value).to eq(county)
        end

        it "populates postcode" do
          expect(fields.find { |f| f.name == "ADDRESS 5 POSTCODE" }.value).to eq(input_values[:vat_person_address][:postcode])
        end

        context "when county is 'Not recorded'" do
          let(:county) { "Not recorded" }

          it "does not populate county field" do
            expect(fields.find { |f| f.name == "ADDRESS 4" }.value).to eq("")
          end
        end
      end

      it "has electricity mpan numbers populated" do
        mpans = onboarding_case_organisation.electricity_meters.map(&:mpan)
        pdf_mapns = (1..13).map { |i| fields.find { |f| f.name == "MPAN#{i}" }.value }.join
        expect(mpans).to include(pdf_mapns)
      end

      it "matches VAT registration no" do
        vat_number = (0..8).map { |i|
          name = i.zero? ? "VAT-REG-NUM" : "VAT-REG-NUM #{i}"
          fields.find { |f| f.name == name }&.value
        }.join
        expect(vat_number).to eq(input_values[:vat_lower_rate_reg_no])
      end

      it "effective date populated with +1 day to contract end date" do
        day_part_1 = fields.find { |f| f.name == "Text Field 42" }.value
        day_part_2 = fields.find { |f| f.name == "Text Field 43" }.value

        effective_date_day = (input_values[:electric_current_contract_end_date] + 1).day.to_s
        expect("#{day_part_1}#{day_part_2}").to eq effective_date_day
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
