# frozen_string_literal: true

module Energy
  class CreateTotalEnergiesVatCertificatePdf
    include Energy::PdfFormsHelper

    attr_reader :input_values

    def initialize(input_values = {})
      @input_values = input_values
    end

    def generate
      raise "Missing template file" unless File.exist?(input_pdf_template_file)

      pdftk.fill_form(input_pdf_template_file, output_pdf_file, form_field_values)
      output_pdf_file
    end

    def input_pdf_template_file
      @input_pdf_template_file ||= INPUT_PDF_TEMPLATE_PATH.join("totalenergies_vat_declaration_certificate_mb.pdf")
    end

    def output_pdf_file
      @output_pdf_file ||= OUTPUT_PDF_PATH.join("filled_totalenergies_vat_declare_certificate_#{Time.current.to_i}.pdf")
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
  end
end
