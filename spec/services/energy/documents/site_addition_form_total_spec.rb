require "rails_helper"

RSpec.describe Energy::Documents::SiteAdditionFormTotal, type: :model do
  subject(:service) { described_class.new(onboarding_case:) }

  let(:support_organisation) { create(:support_organisation, :with_address, name: "Northway School") }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation, **input_values) }
  let(:energy_gas_meter) { create(:energy_gas_meter, :with_valid_data, onboarding_case_organisation:, **gas_meter_values) }

  let(:workbook) { RubyXL::Parser.parse(service.output_file_xl) }
  let(:worksheet) { workbook.worksheets[0] }
  let(:starting_row) { Energy::Documents::SiteAdditionFormTotal::STARTING_ROW_NUMBER }

  let(:gas_supplier) { :edf_energy }
  let(:contract_end_date) { Date.new(2025, 7, 15) }
  let(:meter_type) { :single }
  let(:payment_method) { :bacs }
  let(:payment_term) { :days14 }

  let(:gas_meter_values) do
    {
      mprn: "123456789",
      gas_usage: "1000",
    }
  end

  describe "#call" do
    let(:input_values) do
      {
        gas_current_supplier: gas_supplier,
        gas_current_contract_end_date: contract_end_date,
        gas_single_multi: meter_type,
        billing_payment_method: payment_method,
        billing_payment_terms: payment_term,
        site_contact_first_name: "Jon",
        site_contact_last_name: "Smith",
        site_contact_email: "jonsmith@school.org",
        vat_rate: 20,
        billing_invoicing_method: :paper,
        billing_invoice_address: {
          street: "Downhill",
          locality: "South end",
          town: "London",
          postcode: "NW7 3HS",
        },
      }
    end

    # after { FileUtils.rm_f(service.output_file_xl) }

    describe "creates site addition details on XL document" do
      before do
        energy_gas_meter
        service.call
      end

      it "creates new xl file" do
        expect(File.exist?(service.output_file_xl)).to be true
      end

      it "matches organisation details" do
        expect(worksheet[starting_row][0].value).to eq("Department for Education")
        expect(worksheet[starting_row][1].value).to eq("Sanctuary Bulidings")
        expect(worksheet[starting_row][5].value).to eq("SW1P 3BT")
      end

      it "matches main contact details" do
        expect(worksheet[starting_row][7].value).to eq("Annette")
        expect(worksheet[starting_row][8].value).to eq("Harrison")
        expect(worksheet[starting_row][13].value).to eq("S1 2JF")
        expect(worksheet[starting_row][16].value).to include("education.gov.uk")
      end

      it "matches site and billing addresses" do
        expect(worksheet[starting_row][18].value).to eq(support_organisation.name)
        expect(worksheet[starting_row][21].value).to eq("School")
        expect(worksheet[starting_row][22].value).to eq(input_values[:site_contact_first_name])
        expect(worksheet[starting_row][23].value).to eq(input_values[:site_contact_last_name])
        expect(worksheet[starting_row][25].value).to eq(input_values[:site_contact_email])

        expect(worksheet[starting_row][27].value).to eq(input_values[:billing_invoice_address][:street])
        expect(worksheet[starting_row][29].value).to eq(input_values[:billing_invoice_address][:town])
        expect(worksheet[starting_row][31].value).to eq(input_values[:billing_invoice_address][:postcode])

        expect(worksheet[starting_row][27].value).to eq(input_values[:billing_invoice_address][:street])
        expect(worksheet[starting_row][29].value).to eq(input_values[:billing_invoice_address][:town])
        expect(worksheet[starting_row][31].value).to eq(input_values[:billing_invoice_address][:postcode])

        # Site address
        expect(worksheet[starting_row][33].value).to eq(support_organisation.address["street"])
        expect(worksheet[starting_row][36].value).to eq(support_organisation.address["postcode"])
        expect(worksheet[starting_row][37].value).to eq(support_organisation.address["town"])
      end

      it "matches gas supplier and details" do
        expect(worksheet[starting_row][38].value).to eq("EDF Energy")
        expect(worksheet[starting_row][39].value).to eq(contract_end_date.strftime("%d/%m/%Y"))
        expect(worksheet[starting_row][40].value).to eq("No")
        expect(worksheet[starting_row][41].value).to eq("No")

        expect(worksheet[starting_row][42].value).to eq(gas_meter_values[:mprn])
        expect(worksheet[starting_row][43].value).to eq((contract_end_date + 1.day).strftime("%d/%m/%Y"))
        expect(worksheet[starting_row][44].value).to eq(gas_meter_values[:gas_usage])

        expect(worksheet[starting_row][45].value).to eq("Bacs")
        expect(worksheet[starting_row][46].value).to eq("14")
        expect(worksheet[starting_row][47].value).to eq(20)
        expect(worksheet[starting_row][48].value).to eq("Single meter site")
        expect(worksheet[starting_row][50].value).to eq("Paper")
      end
    end

    describe "single meter" do
      before do
        energy_gas_meter
        service.call
      end

      it "matches meter details" do
        expect(onboarding_case_organisation.gas_meters.count).to eq(1)
        expect(worksheet[starting_row][42].value).to eq(gas_meter_values[:mprn])
        expect(worksheet[starting_row][44].value).to eq(gas_meter_values[:gas_usage])
      end
    end

    describe "multi meter" do
      context "with multiple meters" do
        let(:meter_type) { :multi }
        let(:onboarding_case) { create(:onboarding_case, support_case:) }
        let(:another_onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation, **input_values) }
        let(:gas_meter1) { create(:energy_gas_meter, mprn: 123_456_789, gas_usage: 1000, onboarding_case_organisation: another_onboarding_case_organisation) }
        let(:gas_meter2) { create(:energy_gas_meter, mprn: 223_456_789, gas_usage: 2000, onboarding_case_organisation: another_onboarding_case_organisation) }

        before do
          gas_meter1
          gas_meter2
          service.call
        end

        it "2 meter rows for meter details" do
          expect(another_onboarding_case_organisation.gas_meters.count).to eq(2)
        end

        it "has same organisation details on each row with same data" do
          expect(worksheet[starting_row][0].value).to eq("Department for Education")
          expect(worksheet[starting_row + 1][0].value).to eq("Department for Education")

          expect(worksheet[starting_row][1].value).to eq("Sanctuary Bulidings")
          expect(worksheet[starting_row + 1][1].value).to eq("Sanctuary Bulidings")
        end

        it "has multiple rows for main contact details with same data" do
          expect(worksheet[starting_row][7].value).to eq("Annette")
          expect(worksheet[starting_row + 1][7].value).to eq("Annette")

          expect(worksheet[starting_row][8].value).to eq("Harrison")
          expect(worksheet[starting_row + 1][8].value).to eq("Harrison")

          expect(worksheet[starting_row][13].value).to eq("S1 2JF")
          expect(worksheet[starting_row + 1][13].value).to eq("S1 2JF")
        end

        it "has multiple rows for site and billing addresses with same data" do
          expect(worksheet[starting_row][18].value).to eq(support_organisation.name)
          expect(worksheet[starting_row + 1][18].value).to eq(support_organisation.name)

          expect(worksheet[starting_row][22].value).to eq(input_values[:site_contact_first_name])
          expect(worksheet[starting_row][22].value).to eq(input_values[:site_contact_first_name])

          expect(worksheet[starting_row][25].value).to eq(input_values[:site_contact_email])
          expect(worksheet[starting_row + 1][25].value).to eq(input_values[:site_contact_email])

          expect(worksheet[starting_row][27].value).to eq(input_values[:billing_invoice_address][:street])
          expect(worksheet[starting_row + 1][27].value).to eq(input_values[:billing_invoice_address][:street])

          expect(worksheet[starting_row][31].value).to eq(input_values[:billing_invoice_address][:postcode])
          expect(worksheet[starting_row + 1][31].value).to eq(input_values[:billing_invoice_address][:postcode])

          # Site address
          expect(worksheet[starting_row][33].value).to eq(support_organisation.address["street"])
          expect(worksheet[starting_row + 1][33].value).to eq(support_organisation.address["street"])
          expect(worksheet[starting_row][36].value).to eq(support_organisation.address["postcode"])
          expect(worksheet[starting_row + 1][36].value).to eq(support_organisation.address["postcode"])
        end

        it "has multiple rows for meter details" do
          expect(worksheet[starting_row][38].value).to eq("EDF Energy")
          expect(worksheet[starting_row + 1][38].value).to eq("EDF Energy")

          expect(worksheet[starting_row][42].value).to eq(gas_meter_values[:mprn])
          expect(worksheet[starting_row][42].value).to eq(gas_meter1.mprn)
          expect(worksheet[starting_row + 1][42].value).to eq(gas_meter2.mprn)

          expect(worksheet[starting_row][44].value).to eq(gas_meter1.gas_usage)
          expect(worksheet[starting_row + 1][44].value).to eq(gas_meter2.gas_usage)

          expect(worksheet[starting_row][45].value).to eq("Bacs")
          expect(worksheet[starting_row + 1][45].value).to eq("Bacs")

          expect(worksheet[starting_row][48].value).to eq("Multi meter site")
          expect(worksheet[starting_row + 1][48].value).to eq("Multi meter site")
        end
      end
    end
  end
end
