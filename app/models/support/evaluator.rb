module Support
  class Evaluator < ApplicationRecord
    belongs_to :support_case, class_name: "Support::Case"

    validates :email,
              presence: true,
              email_address: { format: true },
              uniqueness: { case_sensitive: false, scope: :support_case_id }
    validates :first_name, :last_name, presence: true
    belongs_to :user, foreign_key: "dsi_uid", primary_key: "dfe_sign_in_uid", optional: true

    def name
      [first_name, last_name].compact_blank.join(" ")
    end
  end
end
