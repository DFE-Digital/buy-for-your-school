module Energy
  class GenerateSubmissionSummaryPdf
    def initialize(onboarding_case_organisation)
      @support_case = onboarding_case_organisation.onboarding_case.support_case
      @organisation = @support_case.organisation
    end

    def call
      pdf_data = generate_pdf_data
      write_pdf_to_file(pdf_data)
      attach_pdf_to_case
    ensure
      delete_temp_file
    end

  private

    def generate_pdf_data
      html = ApplicationController.render(
        template: "energy/letter_of_authorisations/loa_pdf",
        layout: "pdf",
        assigns: {
          support_case: @support_case,
          organisation: @organisation,
        },
      )

      WickedPdf.new.pdf_from_string(html, encoding: "UTF-8", page_size: "A4")
    end

    def write_pdf_to_file(data)
      File.binwrite(file_path, data)
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

    def file_name
      "DfE Energy for Schools Letter of Agreement_#{@support_case.ref}_#{Date.current}.pdf"
    end

    def file_path
      Rails.root.join("tmp", file_name)
    end

    def delete_temp_file
      File.delete(file_path) if File.exist?(file_path)
    end
  end
end

# onboarding_case_organisation = Energy::OnboardingCaseOrganisation.last
# Energy::GenerateLetterOfAuthorityPdf.new(onboarding_case_organisation).call
