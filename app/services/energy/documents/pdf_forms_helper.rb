# frozen_string_literal: true

module Energy
  module Documents
    module PdfFormsHelper
      PDFTK_PATH = ENV.fetch("PDFTK_PATH", "/usr/local/bin/pdftk").freeze
      INPUT_PDF_TEMPLATE_PATH = Rails.root.join("lib/energy/templates").freeze
      OUTPUT_PDF_PATH = Rails.root.join("tmp/").freeze

      def pdftk
        @pdftk = ::PdfForms.new(PDFTK_PATH)
      end
    end
  end
end
