module Energy
  class Emails::OnboardingFormDdTotalMailer < Energy::Emails::BaseMailer
    FORM_DD_TOTAL_EMAIL_TEMPLATE = "Energy for Schools: gas Direct Debit".freeze

    def default_template
      ApplicationController.renderer.render(
        partial: "energy/letter_of_authorisations/onboarding_form_dd_total_email_template",
      )
    end

  private

    def default_email_subject = "Case #{@support_case.ref} - set up your Direct Debit for gas: Energy for Schools"

    def email_template
      config_template = Energy::EmailTemplateConfiguration.find_by(energy_type: :gas, configure_option: :school_gas_direct_debit_template)
      @email_template ||= if config_template
                            Support::EmailTemplate.find(config_template.support_email_templates_id)
                          else
                            Support::EmailTemplate.find_by(title: FORM_DD_TOTAL_EMAIL_TEMPLATE, archived: false)
                          end
    end

    def default_email_template
      ApplicationController.renderer.render(
        partial: "energy/letter_of_authorisations/onboarding_form_dd_total_email_template",
      )
    end

    def parse_template
      @email_draft.html_content = Energy::Emails::OnboardingFormDdTotalVariableParser.new(@support_case, @onboarding_case_organisation, @email_draft).parse_template
    end
  end
end
