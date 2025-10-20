module Energy
  class Emails::GasSiteAdditionAndPortalAccessMailer < Energy::Emails::BaseMailer
    FORM_SUBMISSION_EMAIL_TEMPLATE = "Total Energies Gas Site Addition and Portal Access".freeze

  private

    def default_email_subject
      organisation = @support_case.organisation
      "Case #{@support_case.ref} - DfE onboarding forms - #{organisation.name} - Gas - Start date #{gas_contract_start_date.strftime('%d %m %Y')}"
    end

    def gas_contract_start_date
      (@onboarding_case_organisation.gas_current_contract_end_date + 1.day).to_date
    end

    def email_template
      @email_template ||= Support::EmailTemplate.find_by(title: FORM_SUBMISSION_EMAIL_TEMPLATE, archived: false)
    end

    def default_email_template
      ApplicationController.renderer.render(
        partial: "energy/letter_of_authorisations/gas_site_addition_and_portal_access_email_template",
      )
    end

    def parse_template
      @email_draft.html_content = Energy::Emails::SiteAdditionAndPortalAccessVariableParser.new(@support_case, @onboarding_case_organisation, @email_draft).parse_template
    end
  end
end
