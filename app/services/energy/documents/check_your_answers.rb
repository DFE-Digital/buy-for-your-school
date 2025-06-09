module Energy
  module Documents
    # rubocop:disable Layout/AccessModifierIndentation
    class CheckYourAnswers
      def initialize(onboarding_case:)
        @onboarding_case = onboarding_case
        @submission_date = @onboarding_case.submitted_at
        @support_case = @onboarding_case.support_case
      end

      def generate
        contents = generate_pdf_data
        write_pdf_to_file(contents)
        attach_pdf_to_case
        contents
      ensure
        delete_temp_file
      end

      private

      def generate_pdf_data
        # There'll only be ONE for single flow, potentially many for MAT flow
        @organisation_task_lists = @onboarding_case.onboarding_case_organisations.map do |org|
          Energy::TaskList.new(org.energy_onboarding_case_id, context: "check")
        end

        html = ApplicationController.render(
          template: "energy/check_your_answers/summary_pdf",
          layout: "pdf",
          assigns: {
            organisation_task_lists: @organisation_task_lists,
            submission_date: @submission_date,
          },
        )

        File.write(Rails.root.join("tmp/test.html"), html)
        WickedPdf.new.pdf_from_string(html, encoding: "UTF-8", page_size: "A4")
      end

      def attach_pdf_to_case
        @support_case.case_attachments.create!(
          attachable: document,
          custom_name: file_name,
          description: "System uploaded document",
        )
      end

      def document
        file = File.open(file_path)
        Support::Document.create!(case: @support_case, file_type: "application/pdf", file:)
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

      def delete_temp_file
        File.delete(file_path) if File.exist?(file_path)
      end
    end
    # rubocop:enable Layout/AccessModifierIndentation
  end
end
