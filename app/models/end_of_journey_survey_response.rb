class EndOfJourneySurveyResponse < ApplicationRecord
  enum :easy_to_use_rating, { strongly_disagree: 0, disagree: 1, neutral: 2, agree: 3, strongly_agree: 4 }, prefix: true
  enum :service, { find_a_framework: 0, request_for_help_form: 1 }, prefix: true

  validates :easy_to_use_rating, presence: { message: "Select how strongly you agree that this form was easy to use" }
end
