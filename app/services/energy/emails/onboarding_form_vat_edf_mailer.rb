module Energy
  class Emails::OnboardingFormVatEdfMailer < Energy::Emails::BaseMailer
    FORM_VAT_EDF_EMAIL_TEMPLATE = "Energy for Schools: electricity VAT certificate".freeze

    def default_template
      ApplicationController.renderer.render(
        partial: "energy/letter_of_authorisations/onboarding_form_vat_edf_email_template",
      )
    end

  private

    def default_email_subject = "Case #{@support_case.ref} - send your VAT certificate for electricity: Energy for Schools "

    def email_template
      config_template = Energy::EmailTemplateConfiguration.find_by(energy_type: :electricity, configure_option: :school_electricity_vat_template)
      @email_template ||= if config_template
                            Support::EmailTemplate.find(config_template.support_email_template_id)
                          else
                            Support::EmailTemplate.find_by(title: FORM_VAT_EDF_EMAIL_TEMPLATE, archived: false)
                          end
    end

    def default_email_template
      ApplicationController.renderer.render(
        partial: "energy/letter_of_authorisations/onboarding_form_vat_edf_email_template",
      )
    end

    def parse_template
      @email_draft.html_content = Energy::Emails::OnboardingFormVatEdfVariableParser.new(@support_case, @onboarding_case_organisation, @email_draft).parse_template
    end
  end
end
