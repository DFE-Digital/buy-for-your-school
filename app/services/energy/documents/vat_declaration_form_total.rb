# frozen_string_literal: true

module Energy
  module Documents
    class VatDeclarationFormTotal < VatDeclarationForm
      TEMPLATE_FILE = "VAT Declaration Total.pdf"

      def input_pdf_template_file
        @input_pdf_template_file ||= INPUT_PDF_TEMPLATE_PATH.join(TEMPLATE_FILE)
      end

      def output_pdf_file
        @output_pdf_file ||= OUTPUT_PDF_PATH.join("TOTAL Declaration of Use Certificate_#{@support_case.ref}_#{Date.current}.pdf")
      end

    private

      def form_field_values
        {
          business_name: input_values[:business_name],
          vat_registration_no: input_values[:vat_registration_no],
          address_line1: input_values[:address_line1],
          address_line2: input_values[:address_line2],
          address_line3: input_values[:city],
          postcode: input_values[:postcode],
          commodity: input_values[:commodity],
          percentage: input_values[:percentage_of_property_rated],
          full_name_and_status_of_signatory: input_values[:full_name_and_status_of_signatory],
          signed: input_values[:signed],
          date: input_values[:date],
        }.merge(gas_mprn_numbers)
      end

      def input_values
        @input_values ||= {
          business_name: @organisation.name,
          vat_registration_no: @onboarding_case_organisation.vat_lower_rate_reg_no,
          address_line1:,
          address_line2:,
          city:,
          postcode:,
          commodity: "Gas",
          percentage_of_property_rated: "#{@onboarding_case_organisation.vat_lower_rate_percentage}%",
          full_name_and_status_of_signatory: vat_person_or_vat_alt_person,
          signed: "",
          date: submitted_date,
        }
      end

      def gas_meters
        @onboarding_case_organisation.gas_meters.map(&:mprn) || []
      end

      def gas_mprn_numbers
        gas_meters.each_with_index.to_h do |mprn, index|
          ["gas_mprn#{index + 1}", mprn]
        end
      end

      def vat_person_or_vat_alt_person
        if @onboarding_case_organisation.vat_person_correct_details
          "#{@onboarding_case_organisation.vat_person_first_name} #{@onboarding_case_organisation.vat_person_last_name}"
        else
          "#{@onboarding_case_organisation.vat_alt_person_first_name} #{@onboarding_case_organisation.vat_alt_person_last_name}"
        end
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

      def city
        address[:town]
      end

      def postcode
        address[:postcode]
      end

      def submitted_date
        (@onboarding_case.submitted_at || Time.current).strftime("%d-%m-%Y")
      end
    end
  end
end
