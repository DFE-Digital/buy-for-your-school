module Energy
  class Emails::DirectDebitVatTotalMailer < Energy::Emails::BaseMailer
    DD_VAT_TOTAL_EMAIL_TEMPLATE = "Energy for Schools: gas VAT and DD instructions".freeze

    def default_template
      ApplicationController.renderer.render(
        partial: "energy/letter_of_authorisations/direct_debit_vat_total_email_template",
      )
    end

  private

    def default_email_subject = "Case #{@support_case.ref} - send your VAT and Direct Debit instructions for gas: Energy for Schools"

    def email_template
      config_template = Energy::EmailTemplateConfiguration.find_by(energy_type: :gas, configure_option: :school_gas_direct_debit_vat_template)
      @email_template ||= if config_template
                            Support::EmailTemplate.find(config_template.support_email_template_id)
                          else
                            Support::EmailTemplate.find_by(title: DD_VAT_TOTAL_EMAIL_TEMPLATE, archived: false)
                          end
    end

    def default_email_template
      ApplicationController.renderer.render(
        partial: "energy/letter_of_authorisations/direct_debit_vat_total_email_template",
      )
    end

    def parse_template
      @email_draft.html_content = Energy::Emails::DirectDebitVatTotalVariableParser.new(@support_case, @onboarding_case_organisation, @email_draft).parse_template
    end
  end
end
