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

    describe "createssite addition details on xl document" do
      before do
        energy_electricity_meter
        service.call
      end

      it "creates new xl file" do
        expect(File.exist?(service.output_file_xl)).to be true
      end

      context "with site and billing addresses" do
        # it "matches site details and address" do
        #   expect(worksheet[starting_row][0].value).to eq(support_organisation.name)
        #   expect(worksheet[starting_row][1].value).to eq(support_organisation.address["street"])
        #   expect(worksheet[starting_row][4].value).to eq(support_organisation.address["postcode"])
        # end

        # it "matches billing address" do
        #   expect(worksheet[starting_row][5].value).to eq(input_values[:billing_invoice_address][:street])
        #   expect(worksheet[starting_row][7].value).to eq(input_values[:billing_invoice_address][:town])
        #   expect(worksheet[starting_row][8].value).to eq(input_values[:billing_invoice_address][:postcode])
        # end
        context "when single school" do
          it "matches site details and address" do
            expect(worksheet[starting_row][0].value).to eq(support_organisation.name)
            expect(worksheet[starting_row][1].value).to eq(support_organisation.address["street"])
            expect(worksheet[starting_row][4].value).to eq(support_organisation.address["postcode"])
          end

          it "matches billing address" do
            expect(worksheet[starting_row][5].value).to eq(input_values[:billing_invoice_address][:street])
            expect(worksheet[starting_row][7].value).to eq(input_values[:billing_invoice_address][:town])
            expect(worksheet[starting_row][8].value).to eq(input_values[:billing_invoice_address][:postcode])
          end
        end
      end

      it "matches contract dates" do
        expect(worksheet[starting_row][9].value).to eq(electricity_end_date.strftime("%d/%m/%Y"))
        expect(worksheet[starting_row][10].value).to eq((electricity_end_date + 1.day).strftime("%d/%m/%Y"))
      end

      context "with bacs" do
        it "matches payment details" do
          expect(worksheet[starting_row][18].value).to eq("BACS")
          expect(worksheet[starting_row][19].value).to eq("14")
          expect(worksheet[starting_row][20].value).to eq("Standard")
          expect(worksheet[starting_row][21].value).to eq("Yes")
        end
      end

      context "with direct debit" do
        let(:payment_method) { :direct_debit }
        let(:payment_term) { :days21 }
        let(:is_bill_consolidated) { false }

        it "matches payment details" do
          expect(worksheet[starting_row][18].value).to eq("Direct Debit")
          expect(worksheet[starting_row][19].value).to eq("21")
          expect(worksheet[starting_row][21].value).to eq("No")
        end
      end

      it "matches key business contact details" do
        expect(worksheet[starting_row][22].value).to eq("Annette Harrison")
        expect(worksheet[starting_row][24].value).to eq("Department for Education")
        expect(worksheet[starting_row][27].value).to eq("SW1P 3BT")
      end
    end

    describe "single meter" do
      before do
        energy_electricity_meter
        service.call
      end

      context "with single meter" do
        it "matches meter details" do
          expect(onboarding_case_organisation.electricity_meters.count).to eq(1)

          expect(worksheet[starting_row][11].value).to eq(electricity_meter_values[:mpan])
          expect(worksheet[starting_row][12].value).to eq("HH")
          expect(worksheet[starting_row][13].value).to eq(electricity_meter_values[:supply_capacity])
          expect(worksheet[starting_row][14].value).to eq(electricity_meter_values[:electricity_usage])

          expect(worksheet[starting_row][15].value).to eq(electricity_meter_values[:data_aggregator])
          expect(worksheet[starting_row][16].value).to eq(electricity_meter_values[:data_collector])
          expect(worksheet[starting_row][17].value).to eq(electricity_meter_values[:meter_operator])
        end
      end
    end

    describe "multi meter" do
      context "with multiple meters" do
        let(:meter_type) { :multi }
        let(:onboarding_case) { create(:onboarding_case, support_case:) }
        let(:another_onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation, **input_values) }
        let(:electicity_meter1) { create(:energy_electricity_meter, :another_meter, onboarding_case_organisation: another_onboarding_case_organisation) }
        let(:electicity_meter2) { create(:energy_electricity_meter, :another_meter, onboarding_case_organisation: another_onboarding_case_organisation) }

        before do
          electicity_meter1
          electicity_meter2
          service.call
        end

        it "2 meter rows for meter details" do
          expect(another_onboarding_case_organisation.electricity_meters.count).to eq(2)
        end

        it "has same organisation details on each row" do
          expect(worksheet[starting_row][0].value).to eq(support_organisation.name)
          expect(worksheet[starting_row + 1][0].value).to eq(support_organisation.name)
        end

        it "has same site details and address on each row" do
          expect(worksheet[starting_row][1].value).to eq(support_organisation.address["street"])
          expect(worksheet[starting_row + 1][1].value).to eq(support_organisation.address["street"])

          expect(worksheet[starting_row][4].value).to eq(support_organisation.address["postcode"])
          expect(worksheet[starting_row + 1][4].value).to eq(support_organisation.address["postcode"])
        end

        it "has multiple rows for each meter" do
          expect(worksheet[starting_row][11].value).to eq(electicity_meter1.mpan)
          expect(worksheet[starting_row + 1][11].value).to eq(electicity_meter2.mpan)
          expect(worksheet[starting_row + 2][11].value).to be_nil

          expect(worksheet[starting_row][13].value).to eq(electicity_meter1.supply_capacity)
          expect(worksheet[starting_row + 1][13].value).to eq(electicity_meter2.supply_capacity)
          expect(worksheet[starting_row + 2][13].value).to be_nil

          expect(worksheet[starting_row][14].value).to eq(electicity_meter1.electricity_usage)
          expect(worksheet[starting_row + 1][14].value).to eq(electicity_meter2.electricity_usage)
          expect(worksheet[starting_row + 3][14].value).to be_nil
        end
      end
    end
  end
end
