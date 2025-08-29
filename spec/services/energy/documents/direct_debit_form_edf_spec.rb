require "rails_helper"

RSpec.describe Energy::Documents::DirectDebitFormEdf, type: :model do
  subject(:service) { described_class.new(onboarding_case:, current_user: user, flatten:) }

  let(:support_organisation) { create(:support_organisation, name: "Bede Academy", telephone_number: "9876543210") }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:flatten) { false }
  let(:onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation) }
  let(:energy_electricity_meter) { create(:energy_electricity_meter, :with_valid_data, onboarding_case_organisation:) }

  let(:fields) { service.pdftk.get_fields(service.output_pdf_file) }
  let(:values) { fields.map(&:value).compact }
  let(:county) { "Northumberland" }

  describe "#call" do
    context "with vat person details" do
      before do
        energy_electricity_meter
        service.call
      end

      it "creates new pdf file" do
        expect(File.exist?(service.output_pdf_file)).to be true
      end

      it "matches the input values with the output pdf" do
        expect(values).to include(support_organisation.name)

        expect(fields.find { |f| f.name == "Check Box 2" }.value).to eq "No"
        expect(fields.find { |f| f.name == "Text Field 1" }.value).to eq support_organisation.name
        expect(fields.find { |f| f.name == "Text Field 12" }.value).to eq "#{user.first_name} #{user.last_name}"
        expect(fields.find { |f| f.name == "Text Field 25" }.value).to eq support_organisation.name
        expect(fields.find { |f| f.name == "Text Field 15" }.value).to eq support_organisation.telephone_number

        energy_electricity_meter.mpan.chars.each_with_index do |mpan_digit, index|
          field_name = "Text Field #{index.zero? ? 26 : 50 + index}"
          expect(fields.find { |f| f.name == field_name }.value).to eq(mpan_digit)
        end
      end
    end
  end
end
