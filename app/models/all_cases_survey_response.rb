class AllCasesSurveyResponse < ApplicationRecord
  belongs_to :case, class_name: "Support::Case", optional: true

  enum status: { sent_out: 0, in_progress: 1, completed: 2 }, _suffix: true

  enum satisfaction_level: { very_dissatisfied: 0, dissatisfied: 1, neither: 2, satisfied: 3, very_satisfied: 4 }, _suffix: true

  enum outcome_achieved: { strongly_disagree: 0, disagree: 1, neither: 2, agree: 3, strongly_agree: 4 }, _suffix: true

  def send_survey!
    self.survey_sent_at = Time.zone.now if survey_sent_at.blank?
    sent_out_status!
  end

  def start_survey!
    self.survey_started_at = Time.zone.now if survey_started_at.blank?
    in_progress_status!
  end

  def complete_survey!
    self.survey_completed_at = Time.zone.now if survey_completed_at.blank?
    completed_status!
  end
end
