require "rails_helper"

RSpec.describe Energy::Documents::SiteAdditionFormTotal, type: :model do
  subject(:service) { described_class.new(onboarding_case:, current_user:) }

  let(:support_organisation) { create(:support_organisation, :with_address, name: "Northway School") }
  let(:current_user) { create(:user, :many_supported_schools_and_groups) }
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
  let(:edf_energy) { "EDF Energy" }

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

    after { FileUtils.rm_f(service.output_file_xl) }

    it "creates site addition details for a single meter" do
      energy_gas_meter
      service.call

      row = worksheet[starting_row]

      aggregate_failures "file output" do
        expect(File.exist?(service.output_file_xl)).to be true
      end

      aggregate_failures "organisation details" do
        expect(row[0].value).to eq(Energy::Documents::SiteAdditionForm::CUSTOMER_NAME)
        expect(row[1].value).to eq(Energy::Documents::SiteAdditionForm::CUSTOMER_ADDRESS_LINE1)
        expect(row[5].value).to eq(Energy::Documents::SiteAdditionForm::CUSTOMER_ADDRESS_POSTCODE)
      end

      aggregate_failures "main contact details" do
        expect(row[7].value).to eq("Annette")
        expect(row[8].value).to eq("Harrison")
        expect(row[13].value).to eq("S1 2JF")
        expect(row[16].value).to include("education.gov.uk")
      end

      aggregate_failures "site and billing addresses" do
        billing_address_line2 = "#{input_values[:billing_invoice_address][:street]}, #{input_values[:billing_invoice_address][:locality]}"
        site_address_line2 = "#{support_organisation.address['street']}, #{support_organisation.address['locality']}"

        expect(row[18].value).to eq(support_organisation.name)
        expect(row[21].value).to eq("School")
        expect(row[22].value).to eq(input_values[:site_contact_first_name])
        expect(row[23].value).to eq(input_values[:site_contact_last_name])
        expect(row[25].value).to eq(input_values[:site_contact_email])
        expect(row[27].value).to eq(support_organisation.name)
        expect(row[28].value).to eq(billing_address_line2)
        expect(row[29].value).to eq(input_values[:billing_invoice_address][:town])
        expect(row[31].value).to eq(input_values[:billing_invoice_address][:postcode])
        expect(row[33].value).to eq(support_organisation.name)
        expect(row[34].value).to eq(site_address_line2)
        expect(row[36].value).to eq(support_organisation.address["postcode"])
        expect(row[37].value).to eq(support_organisation.address["town"])
      end

      aggregate_failures "gas supplier and meter details" do
        expect(onboarding_case_organisation.gas_meters.count).to eq(1)
        expect(row[38].value).to eq(edf_energy)
        expect(row[39].value).to eq(contract_end_date.strftime("%d/%m/%Y"))
        expect(row[40].value).to eq("No")
        expect(row[41].value).to eq("No")
        expect(row[42].value).to eq(gas_meter_values[:mprn])
        expect(row[43].value).to eq((contract_end_date + 1.day).strftime("%d/%m/%Y"))
        expect(row[44].value).to eq(gas_meter_values[:gas_usage])
        expect(row[45].value).to eq("Bacs")
        expect(row[46].value).to eq("14")
        expect(row[47].value).to eq(20)
        expect(row[48].value).to eq("Single meter site")
        expect(row[50].value).to eq("Paper")
        expect(row[52].value).to eq("Email invoice notification with link to TGP Portal")
      end
    end

    context "when gas current supplier is Other" do
      let(:gas_supplier) { :other }
      let(:input_values) do
        super().merge(gas_current_supplier_other: "Other gas supplier")
      end

      it "matches gas supplier name" do
        energy_gas_meter
        service.call

        expect(worksheet[starting_row][38].value).to eq("Other gas supplier")
      end
    end

    context "with multiple meters" do
      let(:meter_type) { :multi }
      let(:another_onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation, **input_values) }
      let(:gas_meter1) { create(:energy_gas_meter, mprn: 123_456_789, gas_usage: 1000, onboarding_case_organisation: another_onboarding_case_organisation) }
      let(:gas_meter2) { create(:energy_gas_meter, mprn: 223_456_789, gas_usage: 2000, onboarding_case_organisation: another_onboarding_case_organisation) }

      it "creates site addition details for each meter" do
        gas_meter1
        gas_meter2
        service.call

        first_row = worksheet[starting_row]
        second_row = worksheet[starting_row + 1]

        aggregate_failures "meter count" do
          expect(another_onboarding_case_organisation.gas_meters.count).to eq(2)
        end

        aggregate_failures "organisation details" do
          expect(first_row[0].value).to eq(Energy::Documents::SiteAdditionForm::CUSTOMER_NAME)
          expect(second_row[0].value).to eq(Energy::Documents::SiteAdditionForm::CUSTOMER_NAME)
          expect(first_row[1].value).to eq(Energy::Documents::SiteAdditionForm::CUSTOMER_ADDRESS_LINE1)
          expect(second_row[1].value).to eq(Energy::Documents::SiteAdditionForm::CUSTOMER_ADDRESS_LINE1)
        end

        aggregate_failures "main contact details" do
          expect(first_row[7].value).to eq("Annette")
          expect(second_row[7].value).to eq("Annette")
          expect(first_row[8].value).to eq("Harrison")
          expect(second_row[8].value).to eq("Harrison")
          expect(first_row[13].value).to eq("S1 2JF")
          expect(second_row[13].value).to eq("S1 2JF")
        end

        aggregate_failures "site and billing addresses" do
          site_address_line2 = "#{support_organisation.address['street']}, #{support_organisation.address['locality']}"

          expect(first_row[18].value).to eq(support_organisation.name)
          expect(second_row[18].value).to eq(support_organisation.name)
          expect(first_row[22].value).to eq(input_values[:site_contact_first_name])
          expect(second_row[22].value).to eq(input_values[:site_contact_first_name])
          expect(first_row[25].value).to eq(input_values[:site_contact_email])
          expect(second_row[25].value).to eq(input_values[:site_contact_email])
          expect(first_row[27].value).to eq(support_organisation.name)
          expect(second_row[27].value).to eq(support_organisation.name)
          expect(first_row[31].value).to eq(input_values[:billing_invoice_address][:postcode])
          expect(second_row[31].value).to eq(input_values[:billing_invoice_address][:postcode])
          expect(first_row[33].value).to eq(support_organisation.name)
          expect(second_row[33].value).to eq(support_organisation.name)
          expect(first_row[34].value).to eq(site_address_line2)
          expect(second_row[34].value).to eq(site_address_line2)
          expect(first_row[36].value).to eq(support_organisation.address["postcode"])
          expect(second_row[36].value).to eq(support_organisation.address["postcode"])
        end

        aggregate_failures "meter details" do
          expect(first_row[38].value).to eq(edf_energy)
          expect(second_row[38].value).to eq(edf_energy)
          expect(first_row[42].value).to eq(gas_meter1.mprn)
          expect(second_row[42].value).to eq(gas_meter2.mprn)
          expect(first_row[44].value).to eq(gas_meter1.gas_usage)
          expect(second_row[44].value).to eq(gas_meter2.gas_usage)
          expect(first_row[45].value).to eq("Bacs")
          expect(second_row[45].value).to eq("Bacs")
          expect(first_row[48].value).to eq("Multi meter site")
          expect(second_row[48].value).to eq("Multi meter site")
        end
      end
    end
  end
end
