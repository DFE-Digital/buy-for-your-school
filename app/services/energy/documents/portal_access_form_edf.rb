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

      def initialize(onboarding_case:, current_user:)
        @onboarding_case = onboarding_case
        @support_case = onboarding_case.support_case
        @organisation = @support_case.organisation
        @onboarding_case_organisation = onboarding_case.onboarding_case_organisations.first
        @current_user = current_user
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
        # @output_file_xl ||= OUTPUT_XL_PATH.join("EDF Power portal Access_#{@support_case.ref}_#{Date.current}.xlsx")
        @output_file_xl ||= OUTPUT_XL_PATH.join("edf_access_#{@support_case.ref}_#{Date.current}.xlsx")
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

      def portal_access_data(electricity_meter)
        {
          "Account No" => "",
          "5% VAT (Y/N)" => vat_rate_yes_no,
          "CCL Exempt (Y/N)" => "Y",
          "Direct Debit (Y/N)" => direct_debit_yes_no,
          "Trust" => establishment_group&.name,
          "School name" => @organisation&.name,
          "post code" => postcode,
          "Power MPAN" => electricity_meter.mpan,
          "Start date" => supply_start_date,
          "Joining Type" => "Site Addition",
          "Email Address for supplier portal access" => email_addresses,
          "Title" => "",
          "Forename" => @current_user.first_name,
          "Surname" => @current_user.last_name,
          "Phone Number" => "foo",
          "Job Title" => "foo",
        }
      end

      def establishment_group
        @establishment_group ||= Support::EstablishmentGroup.find_by(uid: @organisation.trust_code)
      end

      def postcode
        @organisation.address["postcode"]
      end

      def contract_end_date
        @contract_end_date ||= @onboarding_case_organisation.gas_current_contract_end_date
      end

      def supply_start_date
        (contract_end_date + 1.day).strftime("%d/%m/%Y")
      end

      def email_addresses
        @current_user.email
      end

      def vat_rate_yes_no
        @onboarding_case_organisation.vat_rate == 5 ? "Y" : "N"
      end

      def direct_debit_yes_no
        @onboarding_case_organisation.billing_payment_method_direct_debit? ? "Y" : "N"
      end

      def access_type
        @onboarding_case_organisation.billing_invoicing_method_email? ? "Email Push" : "Email Pull"
      end
    end
  end
end
