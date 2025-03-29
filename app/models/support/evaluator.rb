module Support
  class Evaluator < ApplicationRecord
    belongs_to :support_case, class_name: "Support::Case"

    validates :email,
              presence: true,
              email_address: { format: true },
              uniqueness: { case_sensitive: false, scope: :support_case_id }
    validates :first_name, :last_name, presence: true
    belongs_to :user, foreign_key: "dsi_uid", primary_key: "dfe_sign_in_uid", optional: true

    validate :maximum_evaluators_per_case, on: :create

    def name
      [first_name, last_name].compact_blank.join(" ")
    end

    def maximum_evaluators_per_case
      if support_case.evaluators.count >= 100
        errors.add(:base, I18n.t("helpers.label.support_evaluator.maximum_evaluators_per_case"))
      end
    end
  end
end
