# frozen_string_literal: true

module Energy
  module Documents
    class DirectDebitFormEdf < DirectDebitForm
      include AddressHelper

      TEMPLATE_FILE = "direct_debit_single_mpan_number.pdf"
      TEMPLATE_FILE_MULTI = "direct_debit_multi_mpan_number.pdf"

      def input_pdf_template_file
        file_name = is_multi_mpan? ? TEMPLATE_FILE_MULTI : TEMPLATE_FILE
        @input_pdf_template_file ||= INPUT_PDF_TEMPLATE_PATH.join(file_name)
      end

      def output_pdf_file
        @output_pdf_file ||= OUTPUT_PDF_PATH.join("EDF_Direct_Debit_#{@support_case.ref}_#{Date.current}.pdf")
      end

    private

      def form_field_values
        business_details.merge(customer_details)
                        .merge(electricity_mpan_numbers)
                        .merge(multi_mpan_check)
      end

      def business_details
        {
          "Text Field 1" => @organisation_detail.name,
        }
      end

      def customer_details
        {
          "Text Field 12" => name,
          "Text Field 13" => format_address(address),
          "Text Field 25" => @organisation_detail.name,
          "Text Field 16" => address["postcode"],
          "Text Field 15" => @organisation.telephone_number,
        }
      end

      def electricity_mpan_numbers
        electricity_meters.join.to_s.chars.each_with_index.to_h do |digit, index|
          key = if is_multi_mpan?
                  "MPAN #{index + 1}"
                else
                  "Text Field #{index.zero? ? 26 : 50 + index}"
                end
          [key, digit]
        end
      end

      def multi_mpan_check
        {
          "Check Box 2" => is_multi_mpan? ? "Yes" : "No",
        }
      end

      def electricity_meters
        @onboarding_case_organisation.electricity_meters.map(&:mpan) || []
      end

      def is_multi_mpan?
        @onboarding_case_organisation.electricity_meters.size > 1
      end

      def name
        "#{@current_user.first_name} #{@current_user.last_name}"
      end

      def address
        @onboarding_case_organisation.billing_invoice_address || @organisation.address
      end
    end
  end
end
