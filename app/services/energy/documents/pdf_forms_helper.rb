require "pdf_forms"

module Energy
  module Documents
    module PdfFormsHelper
      PDFTK_PATH = ENV.fetch("PDFTK_PATH", "/usr/local/bin/pdftk").freeze
      INPUT_PDF_TEMPLATE_PATH = Rails.root.join("lib/energy/templates").freeze
      OUTPUT_PDF_PATH = Rails.root.join("tmp/").freeze

      def pdftk
        @pdftk = PdfForms.new(PDFTK_PATH)
      end

      def fill_pdf_form(input_pdf_template_file, output_pdf_file, form_field_values, flatten)
        pdftk.fill_form(input_pdf_template_file, output_pdf_file, form_field_values, flatten:)
      end
    end
  end
end
