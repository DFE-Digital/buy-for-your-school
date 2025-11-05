# frozen_string_literal: true

module Energy
  module Documents
    class PortalAccessFormEdf < PortalAccessForm
      TEMPLATE_FILE = "Portal Access Template EDF.xlsx"

      def call
        raise "Missing template file: #{input_template_file_xl}" unless File.exist?(input_template_file_xl)

        electricity_meters.each_with_index do |electricity_meter, row_index|
          portal_access_data = build_portal_access_data(electricity_meter)

          portal_access_data.each_with_index do |(_key, value), column_index|
            cell = worksheet[STARTING_ROW_NUMBER + row_index][column_index]
            next if cell.nil?

            cell.change_contents(value)
          end
        end

        workbook.write(output_file_xl)
      end

      def output_file_xl
        @output_file_xl ||= OUTPUT_XL_PATH.join("EDF Power portal Access_#{@support_case.ref}_#{Date.current}.xlsx")
      end

    private

      def electricity_meters
        @electricity_meters ||= Energy::ElectricityMeter.includes(:onboarding_case_organisation).where(energy_onboarding_case_organisation_id: @onboarding_case_organisation.id)
      end

      def build_portal_access_data(electricity_meter)
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
          "Phone Number" => @organisation.telephone_number,
          "Job Title" => "",
        }
      end

      def contract_end_date
        @contract_end_date ||= @onboarding_case_organisation.electric_current_contract_end_date
      end

      def supply_start_date
        (contract_end_date + 1.day).strftime("%d/%m/%Y")
      end
    end
  end
end
