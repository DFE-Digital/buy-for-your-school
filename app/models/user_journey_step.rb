class UserJourneyStep < ApplicationRecord
  belongs_to :user_journey, class_name: "UserJourney"

  enum product_section: { faf: 0, ghbs_rfh: 1 }, _suffix: true

  validates_uniqueness_of :step_description, scope: [:user_journey_id]
end
