module Support
  class CaseAdditionalContact < ApplicationRecord
    belongs_to :case, class_name: "Support::Case", foreign_key: "support_case_id"
    belongs_to :organisation, class_name: "Support::Organisation", optional: true

    validates :email, presence: true

    def self.role_values
      %w[lead evaluator]
    end
  end
end
