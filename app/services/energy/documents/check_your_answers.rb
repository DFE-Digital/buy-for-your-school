require "wicked_pdf"

module Energy
  module Documents
    class CheckYourAnswers
      def initialize(onboarding_case:)
        @onboarding_case = onboarding_case
        @submission_date = @onboarding_case.submitted_at
        @support_case = @onboarding_case.support_case
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
        @organisation_task_lists = build_organisation_task_lists
        ApplicationController.render(
          template: "energy/check_your_answers/summary_pdf",
          layout: "pdf",
          assigns: {
            organisation_task_lists: @organisation_task_lists,
            submission_date: @submission_date,
          },
        )
      end

      def build_organisation_task_lists
        @onboarding_case.onboarding_case_organisations.map do |org|
          Energy::TaskList.new(org.energy_onboarding_case_id, context: "check")
        end
      end

      def write_pdf_to_file(data)
        File.binwrite(file_path, data)
      end

      def file_name
        "EFS Summary_#{@support_case.ref}_#{@submission_date.strftime('%Y-%m-%d')}.pdf"
      end

      def file_path
        Rails.root.join("tmp", file_name)
      end
    end
  end
end
