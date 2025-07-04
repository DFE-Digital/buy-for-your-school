# frozen_string_literal: true

require "rubyXL"
require "rubyXL/convenience_methods/cell"

module Energy
  module Documents
    class PortalAccessFormEdf
      include Energy::Documents::XlSheetHelper
      TEMPLATE_FILE = "Portal Access Template EDF.xlsx"
      STARTING_ROW_NUMBER = 1
      WORKSHEET_INDEX = 0

      def initialize(onboarding_case:)
        @onboarding_case = onboarding_case
        @support_case = onboarding_case.support_case
        @organisation = @support_case.organisation
        @onboarding_case_organisation = onboarding_case.onboarding_case_organisations.first
      end

      def call
        raise "Missing template file: #{input_template_file_xl}" unless File.exist?(input_template_file_xl)

        electricity_meters.each_with_index do |electricity_meter, row_index|
          portal_access_data(electricity_meter, @onboarding_case_organisation).each_with_index do |(_key, value), column_index|
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
        @output_file_xl ||= OUTPUT_XL_PATH.join("Total portal Access_#{@support_case.ref}_#{Date.current}.xlsx")
      end

    private

      def workbook
        @workbook ||= RubyXL::Parser.parse(input_template_file_xl)
      end

      def worksheet
        @worksheet ||= workbook.worksheets[WORKSHEET_INDEX]
      end

      def electricity_meters
        @electricity_meters ||= Energy::ElectricityMeter.includes(:onboarding_case_organisation).where(energy_onboarding_case_organisation_id: @onboarding_case_organisation.id)
      end

      def portal_access_data(electricity_meter, onboarding_org)
        {
          "Account No" => "",
          "5% VAT (Y/N)" => onboarding_org.vat_rate == 5 ? "Y" : "N",
          "CCL Exempt (Y/N)" => "Y",
          "Direct Debit (Y/N)" => onboarding_org.billing_payment_method == "direct_debit" ? "Y" : "N",
          "Trust" => "foo",
          "School name" => onboarding_org.onboardable.name,
          "post code" => onboarding_org.onboardable.postcode,
          "Power MPAN" => electricity_meter.mpan,
          "Start date" => onboarding_org.electric_current_contract_end_date + 1,
          "Joining Type" => "Site Addition",
          "Email Address for supplier portal access" => "foo",
          "Title" => "foo",
          "Forename" => "foo",
          "Surname" => "foo",
          "Phone Number" => "foo",
          "Job Title" => "foo",
        }
      end
    end
  end
end