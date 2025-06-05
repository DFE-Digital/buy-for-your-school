# frozen_string_literal: true

require "rubyXL"
require "rubyXL/convenience_methods/cell"

module Energy
  class CreateEdfPowerSiteAdditionsXl
    include Energy::XlSheetHelper

    attr_reader :input_values

    STARTING_ROW_NUMBER = 13

    def initialize(input_values = {})
      @input_values = input_values
    end

    def generate
      raise "Missing template file" unless File.exist?(input_xl_template_file)

      worksheet

      cell_input_values.each_with_index do |(_key, value), index|
        cell = worksheet[STARTING_ROW_NUMBER][index]
        next if cell.nil?

        cell.change_contents(value)
      end

      workbook.write(output_xl_file)
    end

    def input_xl_template_file
      @input_xl_template_file ||= INPUT_XL_TEMPLATE_PATH.join("power_site_additions_template.xlsx")
    end

    def output_xl_file
      @output_xl_file ||= OUTPUT_XL_PATH.join("filled_power_site_additions_#{Time.current.to_i}.xlsx")
    end

  private

    def workbook
      @workbook ||= RubyXL::Parser.parse(input_xl_template_file)
    end

    def worksheet
      @worksheet ||= workbook.worksheets[1]
    end

    def cell_input_values
      {
        customer_name: input_values[:customer_name],
        site_address_line_1: input_values[:site_address_line_1],
        site_address_line_2: input_values[:site_address_line_2],
        site_address_city: input_values[:site_address_city],
        site_address_post_code: input_values[:site_address_post_code],
        billing_address_line_1: input_values[:billing_address_line_1],
        billing_address_line_2: input_values[:billing_address_line_2],
        billing_address_city: input_values[:billing_address_city],
        billing_address_postcode: input_values[:billing_address_postcode],
        current_contract_end_date: input_values[:current_contract_end_date],
        supply_start_date_with_edf: input_values[:supply_start_date_with_edf],
        mpan: input_values[:mpan],
        hh_nhh: input_values[:hh_nhh],
        supply_capacity_kva_hh_meters_only: input_values[:supply_capacity_kva_hh_meters_only],
        estimated_annual_consumption_eac: input_values[:estimated_annual_consumption_eac],
        data_aggregator: input_values[:data_aggregator],
        data_collector: input_values[:data_collector],
        meter_operator: input_values[:meter_operator],
        payment_method: input_values[:payment_method],
        payment_durration: input_values[:payment_durration],
        energy_source: input_values[:energy_source],
        consolidated_billing_yes_no: input_values[:consolidated_billing_yes_no],
        key_business_contact_full_name: input_values[:key_business_contact_full_name],
        key_business_contact_email: input_values[:key_business_contact_email],
        company_registered_address_line_1: input_values[:company_registered_address_line_1],
        company_registered_address_line_2: input_values[:company_registered_address_line_2],
        customer_registered_city: input_values[:customer_registered_city],
        company_registered_postcode: input_values[:company_registered_postcode],
        company_registration_charity_number: input_values[:company_registration_charity_number],
      }
    end
  end
end

# Energy::XlGenerator.new({}).generate
