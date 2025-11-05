# frozen_string_literal: true

require "pdf_forms"

module Energy
  module Documents
    class VatDeclarationForm
      PDFTK_PATH = ENV.fetch("PDFTK_PATH", "/usr/local/bin/pdftk").freeze
      INPUT_PDF_TEMPLATE_PATH = Rails.root.join("lib/energy/templates").freeze
      OUTPUT_PDF_PATH = Rails.root.join("tmp/").freeze

      def initialize(onboarding_case:, flatten: true)
        @onboarding_case = onboarding_case
        @support_case = @onboarding_case.support_case
        @organisation = @support_case.organisation
        @onboarding_case_organisation = onboarding_case.onboarding_case_organisations.first
        @flatten = flatten
      end

      def call
        raise "Missing template file" unless File.exist?(input_pdf_template_file)

        pdftk.fill_form(input_pdf_template_file, output_pdf_file, form_field_values, flatten: @flatten)
        output_pdf_file
      end

      def pdftk
        @pdftk ||= PdfForms.new(PDFTK_PATH)
      end
    end
  end
end
