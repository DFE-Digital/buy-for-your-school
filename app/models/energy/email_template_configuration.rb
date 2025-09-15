module Energy
  class EmailTemplateConfiguration < ApplicationRecord
    attr_accessor :template_id, :form_context

    belongs_to :support_email_template, class_name: "Support::EmailTemplate",
                                        foreign_key: "support_email_templates_id", optional: true

    # Constants for energy types and configuration options
    ENERGY_TYPES = { electricity: 0, gas: 1 }.freeze
    CONFIGURE_OPTIONS = {
      electricity_supplier_email: 0,
      electricity_supplier_submitted_template: 1,
      electricity_supplier_direct_debit_template: 2,
      electricity_supplier_vat_template: 3,
      electricity_supplier_direct_debit_vat_template: 4,
      gas_supplier_email: 5,
      gas_supplier_submitted_template: 6,
      gas_supplier_direct_debit_template: 7,
      gas_supplier_vat_template: 8,
      gas_supplier_direct_debit_vat_template: 9,
      school_electricity_direct_debit_template: 10,
      school_electricity_vat_template: 11,
      school_electricity_direct_debit_vat_template: 12,
      school_gas_direct_debit_template: 13,
      school_gas_vat_template: 14,
      school_gas_direct_debit_vat_template: 15,
    }.freeze

    # Enums with prefixes
    enum :energy_type, ENERGY_TYPES, prefix: true
    enum :configure_option, CONFIGURE_OPTIONS, prefix: true

    def self.energy_types
      ENERGY_TYPES
    end

    def self.configure_options
      CONFIGURE_OPTIONS
    end

    # Validations
    validates :to_email_ids, presence: true, if: :requires_email_ids?
    validates :support_email_templates_id, presence: true, if: :requires_template_id?

    validate :validate_email_ids, if: -> { to_email_ids.present? }

    # Instance methods
    def template_name
      support_email_template&.title
    end

  private

    # Check if `to_email_ids` is required based on the configuration option
    def requires_email_ids?
      form_context == "supplier_email_form"
    end

    # Check if `support_email_templates_id` is required based on the configuration option
    def requires_template_id?
      form_context == "email_template_form"
    end

    # Validate the format of email IDs
    def validate_email_ids
      emails = Array(to_email_ids).join(";").split(";").map(&:strip)
      unless emails.all? { |email| URI::MailTo::EMAIL_REGEXP.match?(email) }
        errors.add(:to_email_ids, :invalid_email_ids)
      end
    end
  end
end
