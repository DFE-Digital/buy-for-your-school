class CustomerSatisfactionSurveyResponse < ApplicationRecord
  before_validation :clean_helped_how, if: -> { helped_how_changed? }
  before_save :clean_helped_how_other, if: -> { helped_how_changed? && !helped_how.include?("other") }
  before_save :clean_research_opt_in_values, if: -> { research_opt_in_changed? && research_opt_in == false }

  HELPED_HOW_VALUES = %w[saved_money saved_time helped_buy_better_quality_goods_services improved_confidence improved_capability not_sure none other].freeze

  enum :satisfaction_level, { not_satisfied_at_all: 0, slightly_satisfied: 1, neutral: 2, very_satisfied: 3, extremely_satisfied: 4 }, prefix: true
  enum :easy_to_use_rating, { strongly_disagree: 0, disagree: 1, neutral: 2, agree: 3, strongly_agree: 4 }, prefix: true
  enum :clear_to_use_rating, { strongly_disagree: 0, disagree: 1, neutral: 2, agree: 3, strongly_agree: 4 }, prefix: true
  enum :service, { find_a_framework: 0, create_a_spec: 1, supported_journey: 2, request_for_help_form: 3 }, prefix: true
  enum :source, { exit_survey: 0, banner_link: 1 }, prefix: true
  enum :status, { sent_out: 0, in_progress: 1, completed: 2 }

  validates :satisfaction_level, presence: { message: "Select how satisfied you are with this service" }, on: :satisfaction_level
  validates :easy_to_use_rating, presence: { message: "Select how strongly you agree that this service was easy to use" }, on: :easy_to_use_rating
  validates :helped_how, presence: { message: "Select how this service has helped you" }, inclusion: { in: HELPED_HOW_VALUES }, on: :helped_how
  validates :helped_how_other, presence: { message: "Tell us how else this service has helped you" }, on: :helped_how, if: -> { helped_how.include?("other") }
  validates :clear_to_use_rating, presence: { message: "Select how strongly you agree that it was clear what you could use this service to do" }, on: :clear_to_use_rating
  validates :recommendation_likelihood, presence: { message: "Select how likely you are to recommend us to a colleague on a scale of 0 to 10" }, inclusion: 0..10, on: :recommendation_likelihood
  validates :research_opt_in, inclusion: { in: [true, false], message: "Select whether you would like to participate in research" }, on: :research_opt_in
  validates :research_opt_in_email, presence: { message: "Provide your email address" }, on: :research_opt_in, if: -> { research_opt_in }
  validates :research_opt_in_job_title, presence: { message: "Provide your job title" }, on: :research_opt_in, if: -> { research_opt_in }

  def self.helped_how_values = HELPED_HOW_VALUES

  def start_survey!
    self.survey_started_at = Time.zone.now if survey_started_at.blank?
    in_progress!
  end

  def complete_survey!
    self.survey_completed_at = Time.zone.now if survey_completed_at.blank?
    completed!
  end

private

  def clean_helped_how
    helped_how.compact_blank!
  end

  def clean_helped_how_other
    self.helped_how_other = nil
  end

  def clean_research_opt_in_values
    self.research_opt_in_email = nil
    self.research_opt_in_job_title = nil
  end
end
