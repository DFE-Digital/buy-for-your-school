# frozen_string_literal: true

module Energy
  module Documents
    class PortalAccessFormTotal < PortalAccessForm
      TEMPLATE_FILE = "Portal Access Template Total.xlsx"

      def call
        raise "Missing template file: #{input_template_file_xl}" unless File.exist?(input_template_file_xl)

        gas_meters.each_with_index do |gas_meter, row_index|
          portal_access_data = build_portal_access_data(gas_meter)

          portal_access_data.each_with_index do |(_key, value), column_index|
            cell = worksheet[STARTING_ROW_NUMBER + row_index][column_index]
            next if cell.nil?

            cell.change_contents(value)
          end
        end
        workbook.write(output_file_xl)
      end

      def output_file_xl
        @output_file_xl ||= OUTPUT_XL_PATH.join("Total portal Access_#{@support_case.ref}_#{Date.current}.xlsx")
      end

    private

      def gas_meters
        @gas_meters ||= Energy::GasMeter.includes(:onboarding_case_organisation).where(energy_onboarding_case_organisation_id: @onboarding_case_organisation.id)
      end

      def build_portal_access_data(gas_meter)
        {
          "Trust" => establishment_group&.name,
          "School name" => @organisation&.name,
          "post code" => postcode,
          "GAS MPRN" => gas_meter.mprn,
          "Start date" => supply_start_date,
          "Joining Type" => "Site Addition",
          "Email Address for supplier portal access" => email_addresses,
          "5% VAT (Y/N)" => vat_rate_yes_no,
          "CCL Exempt (Y/N)" => "Y",
          "Direct Debit (Y/N)" => direct_debit_yes_no,
          "Access Type" => access_type,
        }
      end

      def contract_end_date
        @contract_end_date ||= @onboarding_case_organisation.gas_current_contract_end_date
      end

      def supply_start_date
        (contract_end_date + 1.day).strftime("%d/%m/%Y")
      end
    end
  end
end
