# frozen_string_literal: true

module Energy
  module Documents
    class VatDeclarationFormEdf < VatDeclarationForm
      TEMPLATE_FILE = "VAT Declaration Form EDF.pdf"
      BUSINESS_NAME = "Department for Education"

      def input_pdf_template_file
        @input_pdf_template_file ||= INPUT_PDF_TEMPLATE_PATH.join(TEMPLATE_FILE)
      end

      def output_pdf_file
        @output_pdf_file ||= OUTPUT_PDF_PATH.join("EDF Vat Declaration_#{@support_case.ref}_#{Date.current}.pdf")
      end

    private

      def form_field_values
        customer_details.merge(vat_registration_number)
                        .merge(electricity_mpan_numbers)
                        .merge(other_fields)
      end

      def customer_details
        {
          "BUSINESS NAME" => BUSINESS_NAME,
          "ADDRESS 1" => "#{@organisation.name}, #{address_line1}",
          "ADDRESS 2" => address_line2,
          "ADDRESS 3" => city,
          "ADDRESS 4" => address_line3,
          "ADDRESS 5 POSTCODE" => postcode,
          "PERCENT VAT" => vat_lower_percentage[0],
          "PERCENT VAT 1" => vat_lower_percentage[1],
          "PERCENT VAT 2" => vat_lower_percentage[2],
          "ELECTRCITY" => "Yes",
        }
      end

      def vat_registration_number
        vat_registration_no.to_s.chars.each_with_index.to_h do |digit, index|
          vat_field_name = index.zero? ? "VAT-REG-NUM" : "VAT-REG-NUM #{index}"
          [vat_field_name, digit]
        end
      end

      def electricity_mpan_numbers
        electricity_meters.join.to_s.chars.each_with_index.to_h do |digit, index|
          ["MPAN#{index + 1}", digit]
        end
      end

      def other_fields
        {
          "CHARITY" => "Yes",
          "Signature Field 2" => "",
          "FULL NAME" => vat_person_or_vat_alt_person.to_s.upcase,
          "Text Field 35" => submitted_date[0],
          "Text Field 36" => submitted_date[1],
          "Text Field 37" => submitted_date[2],
          "Text Field 38" => submitted_date[3],
          "Text Field 39" => submitted_date[4],
          "Text Field 40" => submitted_date[5],
          "TELEPHONE" => telephone,
          "CERT 1" => "Yes",
          "CERT 2" => "Yes",
          "CERT 3" => "Yes",
          "Text Field 42" => contract_end_date[0],
          "Text Field 43" => contract_end_date[1],
          "Text Field 44" => contract_end_date[2],
          "Text Field 45" => contract_end_date[3],
          "Text Field 46" => contract_end_date[4],
          "Text Field 47" => contract_end_date[5],
        }
      end

      def electricity_meters
        @onboarding_case_organisation.electricity_meters.map(&:mpan) || []
      end

      def vat_person_or_vat_alt_person
        if @onboarding_case_organisation.vat_person_correct_details
          "#{@onboarding_case_organisation.vat_person_first_name} #{@onboarding_case_organisation.vat_person_last_name}"
        else
          "#{@onboarding_case_organisation.vat_alt_person_first_name} #{@onboarding_case_organisation.vat_alt_person_last_name}"
        end
      end

      def telephone
        if @onboarding_case_organisation.vat_person_correct_details
          @onboarding_case_organisation.vat_person_phone
        else
          @onboarding_case_organisation.vat_alt_person_phone
        end
      end

      def vat_lower_percentage
        @onboarding_case_organisation.vat_lower_rate_percentage.to_s
      end

      def contract_end_date
        @contract_end_date ||= (@onboarding_case_organisation.electric_current_contract_end_date + 1.day).strftime("%d%m%y")
      end

      def submitted_date
        @submitted_date ||= (@onboarding_case.submitted_at || Time.current).strftime("%d%m%y")
      end

      def vat_registration_no
        @vat_registration_no ||= @onboarding_case_organisation.vat_lower_rate_reg_no
      end

      def address
        @address ||= if @onboarding_case_organisation.vat_person_correct_details
                       @onboarding_case_organisation.vat_person_address || {}
                     else
                       @onboarding_case_organisation.vat_alt_person_address || {}
                     end.with_indifferent_access
      end

      def address_line1
        address[:street]
      end

      def address_line2
        address[:locality]
      end

      def address_line3
        address[:county]
      end

      def city
        address[:town]
      end

      def postcode
        address[:postcode]
      end
    end
  end
end
