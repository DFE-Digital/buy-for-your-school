# frozen_string_literal: true

require "rubyXL"
require "rubyXL/convenience_methods/cell"

module Energy
  module Documents
    class SiteAdditionFormEdf
      include Energy::Documents::XlSheetHelper
      TEMPLATE_FILE = "Site Addition Form EDF.xlsx"
      STARTING_ROW_NUMBER = 13

      def initialize(onboarding_case:)
        @onboarding_case = onboarding_case
        @support_case = onboarding_case.support_case
        @organisation = @support_case.organisation
        @onboarding_case_organisation = onboarding_case.onboarding_case_organisations.first
      end

      def call
        raise "Missing template file: #{input_template_file_xl}" unless File.exist?(input_template_file_xl)

        electricity_meters.each_with_index do |electricity_meter, row_index|
          site_addition_data = build_site_addition_data(electricity_meter)

          site_addition_data.each_with_index do |(_key, value), column_index|
            cell = worksheet[STARTING_ROW_NUMBER + row_index][column_index]
            next if cell.nil?

            cell.change_contents(value)
          end
        end
        workbook.write(output_file_xl)
      end

      def input_template_file_xl
        @input_template_file_xl ||= INPUT_XL_TEMPLATE_PATH.join(TEMPLATE_FILE)
      end

      def output_file_xl
        @output_file_xl ||= OUTPUT_XL_PATH.join("EDF_XL_#{@support_case.ref}_#{Date.current}.xlsx")
      end

    private

      def workbook
        @workbook ||= RubyXL::Parser.parse(input_template_file_xl)
      end

      def worksheet
        @worksheet ||= workbook.worksheets[1]
      end

      def electricity_meters
        @electricity_meters ||= Energy::ElectricityMeter.includes(:onboarding_case_organisation).where(energy_onboarding_case_organisation_id: @onboarding_case_organisation.id)
      end

      def build_site_addition_data(electricity_meter)
        {
          "Customer Name" => @organisation.name,
          "Site Address Line 1" => site_address_line1,
          "Site Address Line 2" => site_address_line2,
          "Site Address City" => site_address_city,
          "Site Address Post Code" => site_address_postcode,
          "Billing Address Line 1" => billing_address_line1,
          "Billing Address Line 2" => billing_address_line2,
          "Site Address Town" => billing_address_city,
          "Billing Address Postcode" => billing_address_postcode,
          "Current Contract End Date" => contract_end_date.strftime("%d/%m/%Y"),
          "Supply Start Date with EDF" => supply_start_date,
          "MPAN" => electricity_meter.mpan,
          "HH / nHH" => electricity_meter.is_half_hourly ? "HH" : "nHH",
          "Supply Capacity (KVA) - for HH meters only" => electricity_meter.supply_capacity,
          "Estimated Annual Consumption (EAC)" => electricity_meter.electricity_usage,
          "Data Aggregator" => electricity_meter.data_aggregator,
          "Data Collector" => electricity_meter.data_collector,
          "Meter Operator" => electricity_meter.meter_operator,
          "Payment Method" => payment_method,
          "Payment Durration" => @onboarding_case_organisation.billing_payment_terms.to_s[/\d+/],
          "Energy Source" => "Standard",
          "Consolidated Billing (Yes/ No)" => @onboarding_case_organisation.is_electric_bill_consolidated? ? "Yes" : "No",
        }.merge(key_business_information)
      end

      def key_business_information
        {
          "Key Business Contact Full Name" => "Annette Harrison",
          "Key Business Contact Email" => "annette.harrison@education.gov.uk",
          "Company Registered Address Line 1" => "Department for Education",
          "Company Registered Address Line 2" => "Sanctuary Buildings, Great Smith Street",
          "Customer Registered City/Town" => "London",
          "Company Registered Postcode" => "SW1P 3BT",
          "Company Registration/Charity Number" => "N/A",
        }
      end

      def site_address
        @site_address ||= (@organisation.address || {}).with_indifferent_access
      end

      def site_address_line1
        site_address[:street]
      end

      def site_address_line2
        site_address[:locality]
      end

      def site_address_line3
        site_address[:county]
      end

      def site_address_city
        site_address[:town]
      end

      def site_address_postcode
        site_address[:postcode]
      end

      def billing_address
        @billing_address ||= (@onboarding_case_organisation.billing_invoice_address || site_address).with_indifferent_access
      end

      def billing_address_line1
        billing_address[:street]
      end

      def billing_address_line2
        billing_address[:locality]
      end

      def billing_address_line3
        billing_address[:county]
      end

      def billing_address_city
        billing_address[:town]
      end

      def billing_address_postcode
        billing_address[:postcode]
      end

      def contract_end_date
        @contract_end_date ||= @onboarding_case_organisation.electric_current_contract_end_date
      end

      def supply_start_date
        (contract_end_date + 1.day).strftime("%d/%m/%Y")
      end

      def payment_method
        return if @onboarding_case_organisation.billing_payment_method_gov_procurement_card?

        @onboarding_case_organisation.billing_payment_method_bacs? ? "BACS" : "Direct Debit"
      end
    end
  end
end
