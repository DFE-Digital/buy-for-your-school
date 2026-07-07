require "rails_helper"

RSpec.describe Energy::Documents::SiteAdditionFormEdf, type: :model do
  subject(:service) { described_class.new(onboarding_case:, current_user:) }

  let(:support_organisation) { create(:support_organisation, :with_address, name: "Hillside School") }
  let(:current_user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation, **input_values) }
  let(:energy_electricity_meter) { create(:energy_electricity_meter, :with_valid_data, onboarding_case_organisation:, **electricity_meter_values) }

  let(:workbook) { RubyXL::Parser.parse(service.output_file_xl) }
  let(:worksheet) { workbook.worksheets[1] }
  let(:starting_row) { Energy::Documents::SiteAdditionFormEdf::STARTING_ROW_NUMBER } # The value is 13 from the EDF template

  let(:electricity_end_date) { Date.new(2025, 7, 15) }
  let(:meter_type) { :single }
  let(:payment_method) { :bacs }
  let(:payment_term) { :days14 }
  let(:is_bill_consolidated) { true }

  let(:electricity_meter_values) do
    {
      mpan: "0123456789123",
      is_half_hourly: true,
      supply_capacity: "120",
      data_aggregator: "Test Aggregator",
      data_collector: "Test Collector",
      meter_operator: "Test Operator",
      electricity_usage: "230",
    }
  end

  describe "#call" do
    let(:input_values) do
      {
        electric_current_contract_end_date: electricity_end_date,
        electricity_meter_type: meter_type,
        is_electric_bill_consolidated: is_bill_consolidated,
        billing_payment_method: payment_method,
        billing_payment_terms: payment_term,
        billing_invoice_address: {
          street: "456 Secondary St",
          locality: "Suite 5",
          town: "Another City",
          postcode: "WD18 0FV",
        },
      }
    end

    after { FileUtils.rm_f(service.output_file_xl) }

    it "creates site addition details for a single meter" do
      energy_electricity_meter
      service.call

      row = worksheet[starting_row]

      aggregate_failures "file output" do
        expect(File.exist?(service.output_file_xl)).to be true
      end

      aggregate_failures "site details and address" do
        site_address_line2 = "#{support_organisation.address['street']}, #{support_organisation.address['locality']}"

        expect(row[0].value).to eq(Energy::Documents::SiteAdditionForm::CUSTOMER_NAME)
        expect(row[1].value).to eq(support_organisation.name)
        expect(row[2].value).to eq(site_address_line2)
        expect(row[4].value).to eq(support_organisation.address["postcode"])
      end

      aggregate_failures "billing address" do
        billing_address_line2 = "#{input_values[:billing_invoice_address][:street]}, #{input_values[:billing_invoice_address][:locality]}"

        expect(row[5].value).to eq(support_organisation.name)
        expect(row[6].value).to eq(billing_address_line2)
        expect(row[7].value).to eq(input_values[:billing_invoice_address][:town])
        expect(row[8].value).to eq(input_values[:billing_invoice_address][:postcode])
      end

      aggregate_failures "contract dates" do
        expect(row[9].value).to eq(electricity_end_date.strftime("%d/%m/%Y"))
        expect(row[10].value).to eq((electricity_end_date + 1.day).strftime("%d/%m/%Y"))
      end

      aggregate_failures "meter details" do
        expect(onboarding_case_organisation.electricity_meters.count).to eq(1)
        expect(row[11].value).to eq(electricity_meter_values[:mpan])
        expect(row[12].value).to eq("HH")
        expect(row[13].value).to eq(electricity_meter_values[:supply_capacity])
        expect(row[14].value).to eq(electricity_meter_values[:electricity_usage])
        expect(row[15].value).to eq(electricity_meter_values[:data_aggregator])
        expect(row[16].value).to eq(electricity_meter_values[:data_collector])
        expect(row[17].value).to eq(electricity_meter_values[:meter_operator])
      end

      aggregate_failures "payment details" do
        expect(row[18].value).to eq("BACS")
        expect(row[19].value).to eq("14")
        expect(row[20].value).to eq("Standard")
        expect(row[21].value).to eq("Yes")
      end

      aggregate_failures "key business contact details" do
        expect(row[22].value).to eq("Annette Harrison")
        expect(row[24].value).to eq("Department for Education")
        expect(row[27].value).to eq("SW1P 3BT")
      end
    end

    context "with direct debit" do
      let(:payment_method) { :direct_debit }
      let(:payment_term) { :days21 }
      let(:is_bill_consolidated) { false }

      it "matches payment details" do
        energy_electricity_meter
        service.call

        row = worksheet[starting_row]

        aggregate_failures "payment details" do
          expect(row[18].value).to eq("Direct Debit")
          expect(row[19].value).to eq("21")
          expect(row[21].value).to eq("No")
        end
      end
    end

    context "with multiple meters" do
      let(:meter_type) { :multi }
      let(:another_onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation, **input_values) }
      let(:electricity_meter1) { create(:energy_electricity_meter, :another_meter, onboarding_case_organisation: another_onboarding_case_organisation) }
      let(:electricity_meter2) { create(:energy_electricity_meter, :another_meter, onboarding_case_organisation: another_onboarding_case_organisation) }

      it "creates site addition details for each meter" do
        electricity_meter1
        electricity_meter2
        service.call

        first_row = worksheet[starting_row]
        second_row = worksheet[starting_row + 1]

        aggregate_failures "meter count" do
          expect(another_onboarding_case_organisation.electricity_meters.count).to eq(2)
        end

        aggregate_failures "organisation details" do
          expect(first_row[0].value).to eq(Energy::Documents::SiteAdditionForm::CUSTOMER_NAME)
          expect(second_row[0].value).to eq(Energy::Documents::SiteAdditionForm::CUSTOMER_NAME)
        end

        aggregate_failures "site details and address" do
          expect(first_row[1].value).to eq(support_organisation.name)
          expect(second_row[1].value).to eq(support_organisation.name)
          expect(first_row[4].value).to eq(support_organisation.address["postcode"])
          expect(second_row[4].value).to eq(support_organisation.address["postcode"])
        end

        aggregate_failures "meter details" do
          expect(first_row[11].value).to eq(electricity_meter1.mpan)
          expect(second_row[11].value).to eq(electricity_meter2.mpan)
          expect(worksheet[starting_row + 2][11].value).to be_nil
          expect(first_row[13].value).to eq(electricity_meter1.supply_capacity)
          expect(second_row[13].value).to eq(electricity_meter2.supply_capacity)
          expect(worksheet[starting_row + 2][13].value).to be_nil
          expect(first_row[14].value).to eq(electricity_meter1.electricity_usage)
          expect(second_row[14].value).to eq(electricity_meter2.electricity_usage)
          expect(worksheet[starting_row + 3][14].value).to be_nil
        end
      end
    end
  end
end
