module Support
  class ContractRecipient < ApplicationRecord
    belongs_to :support_case, class_name: "Support::Case"

    validates :email,
              presence: true,
              format: { with: URI::MailTo::EMAIL_REGEXP },
              uniqueness: { case_sensitive: false, scope: :support_case_id }
    validates :first_name, :last_name, presence: true, length: { maximum: 60 }
    belongs_to :user, foreign_key: "dsi_uid", primary_key: "dfe_sign_in_uid", optional: true

    validate :maximum_contract_recipients_per_case, on: :create

    def name
      [first_name, last_name].compact_blank.join(" ")
    end

    def maximum_contract_recipients_per_case
      if support_case.contract_recipients.count >= 100
        errors.add(:base, I18n.t("helpers.label.support_contract_recipient.maximum_contract_recipients_per_case"))
      end
    end
  end
end
