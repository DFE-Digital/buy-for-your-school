module Energy
  class Emails::NonDirectDebitVatTotalMailer < Energy::Emails::BaseMailer
    NON_DIRECT_DEBIT_VAT_TOTAL_EMAIL_TEMPLATE = "Energy for Schools: gas VAT certificate".freeze
    TOTAL_ENERGIES_VAT_EMAIL = "ccs@totalenergies.com".freeze

    def default_template
      ApplicationController.renderer.render(
        partial: "energy/letter_of_authorisations/non_direct_debit_vat_total_email_template",
      )
    end

  private

    def default_email_subject = "Case #{@support_case.ref} - send your VAT certificate for gas: Energy for Schools"

    def email_template
      config_template = Energy::EmailTemplateConfiguration.find_by(energy_type: :gas, configure_option: :school_gas_vat_template)
      @email_template ||= if config_template
                            Support::EmailTemplate.find(config_template.support_email_template_id)
                          else
                            Support::EmailTemplate.find_by(title: NON_DIRECT_DEBIT_VAT_TOTAL_EMAIL_TEMPLATE, archived: false)
                          end
    end

    def default_email_template
      ApplicationController.renderer.render(
        partial: "energy/letter_of_authorisations/non_direct_debit_vat_total_email_template",
      )
    end

    def parse_template
      @email_draft.html_content = Energy::Emails::NonDirectDebitVatTotalVariableParser.new(@support_case, @onboarding_case_organisation, @email_draft).parse_template
    end
  end
end
