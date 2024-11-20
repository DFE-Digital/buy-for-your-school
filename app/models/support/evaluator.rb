module Support
  class Evaluator < ApplicationRecord
    belongs_to :support_case, class_name: "Support::Case"

    include HasNormalizedEmail

    validates :email,
              presence: true,
              uniqueness: { case_sensitive: false, scope: :support_case_id }
    validates :first_name, :last_name, presence: true
  end
end
