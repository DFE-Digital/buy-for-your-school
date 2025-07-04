require "rails_helper"

RSpec.describe Energy::Documents::PortalAccessFormEdf, type: :model do
  subject(:service) { described_class.new(onboarding_case:, current_user:) }

  let(:organisation) { create(:support_organisation, :with_address, name: "Northway School") }
  let(:current_user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation:) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: organisation, **input_values) }
  let(:energy_electricity_meter) { create(:energy_electricity_meter, :with_valid_data, onboarding_case_organisation:, **electricity_meter_values) }

  let(:workbook) { RubyXL::Parser.parse(service.output_file_xl) }
  let(:worksheet) { workbook.worksheets[0] }
  let(:starting_row) { Energy::Documents::PortalAccessFormEdf::STARTING_ROW_NUMBER }

  let(:establishment_group) { create(:establishment_group, name: "Department for Education") }
  let(:postcode) { "S1 2JF" }
  let(:electricity_supplier) { :edf_energy }
  let(:contract_end_date) { Date.new(2025, 7, 15) }
  let(:meter_type) { :single }
  let(:payment_method) { :direct_debit }
  let(:payment_term) { :days14 }

  let(:electricity_meter_values) do
    {
      mpan: "2002002002002",
      supply_capacity: "120",
      electricity_usage: "230",
    }
  end

  describe "#call" do
    let(:input_values) do
      {
        electric_current_supplier: electricity_supplier,
        electric_current_contract_end_date: contract_end_date,
        electricity_meter_type: meter_type,
        billing_payment_method: payment_method,
        site_contact_email: "jonsmith@school.org",
        vat_rate: 5,
        billing_invoicing_method: :paper,
      }
    end

    after { FileUtils.rm_f(service.output_file_xl) }

    describe "creates site addition details on XL document" do
      before do
        energy_electricity_meter
        service.call
      end

      it "creates new xl file" do
        expect(File.exist?(service.output_file_xl)).to be true
      end

      it "Matches portal access details" do
        expect(worksheet[starting_row][0].value).to eq("")
        expect(worksheet[starting_row][1].value).to eq("Y")
        expect(worksheet[starting_row][2].value).to eq("Y")
        expect(worksheet[starting_row][3].value).to eq("Y")
        expect(worksheet[starting_row][3].value).to eq("Y")
        expect(worksheet[starting_row][4].value).to eq("")
        expect(worksheet[starting_row][5].value).to eq(organisation.name)
        expect(worksheet[starting_row][6].value).to eq(organisation.address["postcode"])
        expect(worksheet[starting_row][7].value).to eq(energy_electricity_meter.mpan)
        expect(worksheet[starting_row][8].value).to eq((contract_end_date + 1.day).strftime("%d/%m/%Y"))
        expect(worksheet[starting_row][9].value).to eq("Site Addition")
        expect(worksheet[starting_row][10].value).to eq(current_user.email)
        expect(worksheet[starting_row][11].value).to eq("")
        expect(worksheet[starting_row][12].value).to eq(current_user.first_name)
        expect(worksheet[starting_row][13].value).to eq(current_user.last_name)
        expect(worksheet[starting_row][14].value).to eq("")
        expect(worksheet[starting_row][15].value).to eq("")
      end
    end

    describe "single meter" do
      before do
        energy_electricity_meter
        service.call
      end

      it "has single row for portal access details" do
        expect(onboarding_case_organisation.electricity_meters.count).to eq(1)
        expect(worksheet[starting_row][7].value).to eq(electricity_meter_values[:mpan])
      end

      it "has single row for meter details" do
        expect(worksheet[starting_row][7].value).to eq(electricity_meter_values[:mpan])
        expect(worksheet[starting_row + 1][7].value).to be_nil
      end
    end

    describe "multi meter" do
      context "with multiple meters" do
        let(:meter_type) { :multi }
        let(:onboarding_case) { create(:onboarding_case, support_case:) }
        let(:another_onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: organisation, **input_values) }
        let(:electricity_meter1) { create(:energy_electricity_meter, :another_meter, onboarding_case_organisation: another_onboarding_case_organisation) }
        let(:electricity_meter2) { create(:energy_electricity_meter, :another_meter, onboarding_case_organisation: another_onboarding_case_organisation) }

        before do
          electricity_meter1
          electricity_meter2
          service.call
        end

        it "2 meter rows for meter details" do
          expect(another_onboarding_case_organisation.electricity_meters.count).to eq(2)
        end

        it "has multiple rows for portal access details" do
          expect(worksheet[starting_row][0].value).to eq("")
          expect(worksheet[starting_row][5].value).to eq(organisation.name)
          expect(worksheet[starting_row + 1][5].value).to eq(organisation.name)

          expect(worksheet[starting_row][6].value).to eq(organisation.address["postcode"])
          expect(worksheet[starting_row + 1][6].value).to eq(organisation.address["postcode"])
        end

        it "has multiple rows for meter details" do
          expect(worksheet[starting_row][7].value).to eq(electricity_meter1.mpan)
          expect(worksheet[starting_row + 1][7].value).to eq(electricity_meter2.mpan)
        end
      end
    end
  end
end
