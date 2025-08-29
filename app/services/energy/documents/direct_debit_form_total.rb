# frozen_string_literal: true

module Energy
  module Documents
    class DirectDebitFormTotal < DirectDebitForm
      include AddressHelper

      TEMPLATE_FILE = "DD Form Total - single.pdf"
      TEMPLATE_FILE_MULTI = "DD Form Total - multi.pdf"

      def input_pdf_template_file
        file_name = is_multi_mprn? ? TEMPLATE_FILE_MULTI : TEMPLATE_FILE
        @input_pdf_template_file ||= INPUT_PDF_TEMPLATE_PATH.join(file_name)
      end

      def output_pdf_file
        @output_pdf_file ||= OUTPUT_PDF_PATH.join("TOTAL_Direct_Debit_#{@support_case.ref}_#{Date.current}.pdf")
      end

    private

      def form_field_values
        {
          Company: input_values[:company_name],
          "Address-1": input_values[:address_line1],
          "Address-2": input_values[:address_line2],
          "Address-3": input_values[:city],
          "Post Code 1": input_values[:postcode],
          MPR: is_multi_mprn? ? nil : input_values[:mprn],
        }.merge(is_multi_mprn? ? build_mprns : {})
      end

      def input_values
        @input_values ||= {
          company_name: @organisation.name,
          address_line1:,
          address_line2:,
          city:,
          postcode:,
          mprn: single_mprn,
          mprn1: mprns[0],
          mprn2: mprns[1],
          mprn3: mprns[2],
          mprn4: mprns[3],
          mprn5: mprns[4],
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
        (@onboarding_case_organisation.billing_invoice_address || @organisation.address).with_indifferent_access
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

      def is_multi_mprn?
        @onboarding_case_organisation.gas_meters.size > 1
      end

      def single_mprn
        @onboarding_case_organisation.gas_meters.first.mprn
      end

      def mprns
        return @mprns if @mprns

        numbers = @onboarding_case_organisation.gas_meters.map(&:mprn).sort
        @mprns = numbers.fill(nil, numbers.size, Energy::ApplicationController::MAX_METER_COUNT - numbers.size)
      end

      def build_mprns
        numbers = @onboarding_case_organisation.gas_meters.map(&:mprn).sort
        out = {}

        numbers.each_with_index do |num, row|
          num.split("").each_with_index do |digit, col|
            key = "m#{row + 1}-#{col + 1}".to_sym
            out[key] = digit
          end
        end

        out
      end
    end
  end
end
