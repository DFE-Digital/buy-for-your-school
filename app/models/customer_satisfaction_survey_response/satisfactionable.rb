module CustomerSatisfactionSurveyResponse::Satisfactionable
  extend ActiveSupport::Concern

  included do
    enum :satisfaction_level, { very_dissatisfied: 0, dissatisfied: 1, neither: 2, satisfied: 3, very_satisfied: 4 }, prefix: true
    validates :satisfaction_level, presence: { message: "Select how satisfied you are with this service" }, on: :satisfaction_level
  end
end
