class UserJourney < ApplicationRecord
  belongs_to :case, class_name: "Support::Case", optional: true
  belongs_to :framework_request, class_name: "FrameworkRequest", optional: true
  has_many :user_journey_steps, class_name: "UserJourneyStep"

  enum status: { in_progress: 0, complete: 1, case_created: 2 }

  scope :by_session_id, ->(session_id) { joins(:user_journey_steps).where("user_journey_steps.session_id" => session_id).distinct }
end
