module CustomerSatisfactionSurveyResponse::Satisfactionable
  extend ActiveSupport::Concern

  included do
    enum :satisfaction_level, { not_satisfied_at_all: 0, slightly_satisfied: 1, neutral: 2, very_satisfied: 3, extremely_satisfied: 4 }, prefix: true
    validates :satisfaction_level, presence: { message: "Select how satisfied you are with this service" }, on: :satisfaction_level
  end
end
