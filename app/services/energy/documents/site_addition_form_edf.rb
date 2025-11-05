# frozen_string_literal: true

module Energy
  module Documents
    class SiteAdditionFormEdf < SiteAdditionForm
      TEMPLATE_FILE = "Site Addition Form EDF.xlsx"
      STARTING_ROW_NUMBER = 13
      WORKSHEET_INDEX = 1

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

      def output_file_xl
        @output_file_xl ||= OUTPUT_XL_PATH.join("EDF Site Addition_#{@support_case.ref}_#{Date.current}.xlsx")
      end

    private

      def electricity_meters
        @electricity_meters ||= Energy::ElectricityMeter.includes(:onboarding_case_organisation).where(energy_onboarding_case_organisation_id: @onboarding_case_organisation.id)
      end

      def build_site_addition_data(electricity_meter)
        {
          "Customer Name" => CUSTOMER_NAME,
          "Site Address Line 1" => site_address_line1,
          "Site Address Line 2" => site_address_line2,
          "Site Address City" => site_address_city,
          "Site Address Post Code" => site_address_postcode,
          "Billing Address Line 1" => billing_address_line1,
          "Billing Address Line 2" => billing_address_line2,
          "Site Address Town" => billing_address_city,
          "Billing Address Postcode" => billing_address_postcode,
          "Current Contract End Date" => electicity_contract_end_date.strftime("%d/%m/%Y"),
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
          "Company Registered Address Line 1" => CUSTOMER_NAME,
          "Company Registered Address Line 2" => "#{CUSTOMER_ADDRESS_LINE1}, #{CUSTOMER_ADDRESS_LINE2}",
          "Customer Registered City/Town" => CUSTOMER_ADDRESS_CITY,
          "Company Registered Postcode" => CUSTOMER_ADDRESS_POSTCODE,
          "Company Registration/Charity Number" => "N/A",
        }
      end

      def electicity_contract_end_date
        @electicity_contract_end_date ||= @onboarding_case_organisation.electric_current_contract_end_date
      end

      def supply_start_date
        (electicity_contract_end_date + 1.day).strftime("%d/%m/%Y")
      end

      def payment_method
        @onboarding_case_organisation.billing_payment_method_bacs? ? "BACS" : "Direct Debit"
      end
    end
  end
end
