# frozen_string_literal: true

module Energy
  module Documents
    class LetterOfAuthority
      def initialize(onboarding_case:)
        @support_case = onboarding_case.support_case
        @organisation = @support_case.organisation
      end

      def call
        write_pdf_to_file(generate_pdf)
        file_path
      end

    private

      def generate_pdf
        html = render_html
        WickedPdf.new.pdf_from_string(html, encoding: "UTF-8", page_size: "A4")
      end

      def render_html
        ApplicationController.render(
          template: "energy/letter_of_authorisations/loa_pdf",
          layout: "pdf",
          assigns: {
            support_case: @support_case,
            organisation: @organisation,
          },
        )
      end

      def write_pdf_to_file(data)
        File.binwrite(file_path, data)
      end

      def file_name
        "DfE Energy for Schools Letter of Agreement_#{@support_case.ref}_#{Date.current}.pdf"
      end

      def file_path
        Rails.root.join("tmp", file_name)
      end
    end
  end
end
