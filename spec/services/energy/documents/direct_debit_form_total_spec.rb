require "rails_helper"

RSpec.describe Energy::Documents::DirectDebitFormTotal, type: :model do
  subject(:service) { described_class.new(onboarding_case:, current_user: user, flatten:) }

  let(:support_organisation) { create(:support_organisation, name: "Bede Academy", telephone_number: "9876543210") }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:flatten) { false }
  let(:onboarding_case_organisation) { create(:energy_onboarding_case_organisation, :with_billing_address, onboarding_case:, onboardable: support_organisation) }
  let!(:gas_meter) { create(:energy_gas_meter, :with_valid_data, mprn: "121212", onboarding_case_organisation:) }

  let(:fields) { service.pdftk.get_fields(service.output_pdf_file) }
  let(:values) { fields.map(&:value).compact }
  let(:county) { "Northumberland" }

  describe "#call" do
    context "with a single meter" do
      before { service.call }

      it "creates new pdf file" do
        expect(File.exist?(service.output_pdf_file)).to be true
      end

      it "matches the input values with the output pdf" do
        # Service User Number Default to: 856723 Always populate
        # Freepost address Default to: Major Business Credit TotalEnergies Gas & Power Bridge Gate, 55-57 High Street, Redhill, Surrey RH1 1RX Always populate

        # Direct debit payments to match our invoices: Company Name Site/Trust Name selected from online form where user selects the address of the payment School/Trust name - always populate with which one is selected
        expect(values).to include(support_organisation.name)

        # Direct debit payments to match our invoices: Address Address of the Site/Trust selected from above School/Trust Address - always populate with which one is selected
        expect(fields.find { |f| f.name == "Address-1" }.value).to match(/Foot St/)
        expect(fields.find { |f| f.name == "Address-2" }.value).to match(/Marsh House/)

        # Direct debit payments to match our invoices: Postcode Postcode of the Site/Trust selected from above School/Trust postcode - always populate with which one is selected
        expect(fields.find { |f| f.name == "Post Code 1" }.value).to eq("NE32 2TY")

        # MPRN (Single) MPRN value from online form Always populate
        expect(fields.find { |f| f.name == "MPR" }.value).to eq gas_meter.mprn

        # All other fields leave blank Leave blank School to populate
      end
    end

    context "with multiple meters" do
      let!(:gas_meter_2) { create(:energy_gas_meter, :with_valid_data, mprn: "242424", onboarding_case_organisation:) }
      let!(:gas_meter_3) { create(:energy_gas_meter, :with_valid_data, mprn: "353535", onboarding_case_organisation:) }

      before { service.call }

      it "fills in address as expected" do
        expect(fields.find { |f| f.name == "Address-1" }.value).to match(/Foot St/)
        expect(fields.find { |f| f.name == "Address-2" }.value).to match(/Marsh House/)
        expect(fields.find { |f| f.name == "Post Code 1" }.value).to eq("NE32 2TY")
      end

      it "leaves the single meter number field blank" do
        expect(fields.find { |f| f.name == "MPR" }.value).to eq ""
      end

      it "puts meter numbers on second page" do
        # Multiple MPRN list MPRN count > 1 Include Second page of this PDF with box layout with multiple MPRN With title ‘Multiple MPRN listed below’
        expect(fields.find { |f| f.name == "m1-1" }.value).to eq gas_meter.mprn.split("").first
        expect(fields.find { |f| f.name == "m1-6" }.value).to eq gas_meter.mprn.split("").last
        expect(fields.find { |f| f.name == "m2-1" }.value).to eq gas_meter_2.mprn.split("").first
        expect(fields.find { |f| f.name == "m2-6" }.value).to eq gas_meter_2.mprn.split("").last
        expect(fields.find { |f| f.name == "m3-1" }.value).to eq gas_meter_3.mprn.split("").first
        expect(fields.find { |f| f.name == "m3-6" }.value).to eq gas_meter_3.mprn.split("").last
      end
    end
  end
end
