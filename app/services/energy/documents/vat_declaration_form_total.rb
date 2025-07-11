# frozen_string_literal: true

module Energy
  module Documents
    class VatDeclarationFormTotal
      include Energy::Documents::PdfFormsHelper
      TEMPLATE_FILE = "VAT Declaration Total.pdf"

      def initialize(onboarding_case:)
        @onboarding_case = onboarding_case
        @support_case = @onboarding_case.support_case
        @organisation = @support_case.organisation
        @onboarding_case_organisation = onboarding_case.onboarding_case_organisations.first
      end

      def call
        raise "Missing template file" unless File.exist?(input_pdf_template_file)

        pdftk.fill_form(input_pdf_template_file, output_pdf_file, form_field_values, flatten: true)
        output_pdf_file
      end

      def input_pdf_template_file
        @input_pdf_template_file ||= INPUT_PDF_TEMPLATE_PATH.join(TEMPLATE_FILE)
      end

      def output_pdf_file
        @output_pdf_file ||= OUTPUT_PDF_PATH.join("TOTAL Declaration of Use Certificate_#{@support_case.ref}_#{Date.current}.pdf")
      end

    private

      def form_field_values
        {
          Text3: input_values[:business_name],
          Text4: input_values[:vat_registration_no],
          Text5: input_values[:address_line1],
          Text6: input_values[:address_line2],
          Text7: input_values[:city],
          Text8: input_values[:postcode],
          Text9: input_values[:commodity],
          Text10: input_values[:percentage_of_property_rated],
          Text11: input_values[:full_name_and_status_of_signatory],
          Text12: input_values[:signed],
          Text13: input_values[:date],
        }
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
