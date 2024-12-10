module Support
  class Evaluator < ApplicationRecord
    belongs_to :support_case, class_name: "Support::Case"

    validates :email,
              presence: true,
              format: { with: URI::MailTo::EMAIL_REGEXP },
              uniqueness: { case_sensitive: false, scope: :support_case_id }
    validates :first_name, :last_name, presence: true

    def name
      [first_name, last_name].compact_blank.join(" ")
    end
  end
end
