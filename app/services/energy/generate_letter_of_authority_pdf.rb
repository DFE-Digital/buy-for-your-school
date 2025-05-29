module Energy
  class GenerateLetterOfAuthorityPdf
    def initialize(onboarding_case_organisation)
      @support_case = onboarding_case_organisation.onboarding_case.support_case
      @organisation = @support_case.organisation
    end

    def call
      html = ApplicationController.render(
        template: "energy/letter_of_authorisations/loa_pdf",
        layout: "pdf",
        assigns: {
          support_case: @support_case,
          organisation: @organisation,
        },
      )

      WickedPdf.new.pdf_from_string(
        html,
        encoding: "UTF-8",
        page_size: "A4",
        # margin: { top: 20, bottom: 20, left: 20, right: 20 },
      )
    end
  end
end

# loa_submitted and update successfully.
# Redirect to submitted page
# At background
# generate LOA pdf
# attached LOA to support case
# Draft email
# send email with LOA pdf attachment
