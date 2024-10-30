# Capture user feedback
#
class UserFeedback < ApplicationRecord
  self.table_name = "user_feedback"

  belongs_to :logged_in_as, class_name: "User", optional: true

  # Service
  #
  #   create_a_specification
  enum :service, { create_a_specification: 0 }

  # Satisfaction rating
  #
  #   very_dissatisfied
  #   dissatisfied
  #   neither - Neither satisfied or dissatisfied
  #   satisfied
  #   very_satisfied
  enum :satisfaction, { very_dissatisfied: 0, dissatisfied: 1, neither: 2, satisfied: 3, very_satisfied: 4 }
end
