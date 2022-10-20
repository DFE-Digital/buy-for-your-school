class UserJourney < ApplicationRecord
  belongs_to :case, class_name: "Support::Case", optional: true

  enum status: { in_progress: 0, complete: 1, case_created: 2 }
end
