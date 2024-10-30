class UserJourneyStep < ApplicationRecord
  belongs_to :user_journey, class_name: "UserJourney"

  enum :product_section, { faf: 0, ghbs_rfh: 1, ghbs_specify: 2, govuk: 3 }, suffix: true
end
