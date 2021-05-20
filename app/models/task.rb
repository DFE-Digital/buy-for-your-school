class Task < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :section
  has_many :steps, dependent: :destroy

  validates :title, :contentful_id, presence: true

  attr_accessor

  NOT_STARTED = 0
  IN_PROGRESS = 1
  COMPLETED = 2

  def visible_steps
    steps.where(hidden: false)
  end

  def visible_steps_count
    visible_steps.count
  end

  def has_single_visible_step?
    visible_steps_count == 1
  end

  def answered_questions_count
    visible_steps_with_answers.count
  end

  def status
    return COMPLETED if answered_questions_count == visible_steps_count
    return IN_PROGRESS if answered_questions_count.positive?

    NOT_STARTED
  end

  def all_steps_answered?
    eager_loaded_visible_steps.all?(&:answered?)
  end

  def visible_steps_with_answers
    eager_loaded_visible_steps.select(&:answered?)
  end

  def next_unanswered_step_id
    step_ids = eager_loaded_visible_steps.pluck(:id)
    answered_step_ids = visible_steps_with_answers.pluck(:id)

    remaining_ids = step_ids - answered_step_ids

    return nil if remaining_ids.empty?

    remaining_ids.first
  end

  def eager_loaded_visible_steps
    @eager_loaded_visible_steps ||= visible_steps.includes(
      %i[short_text_answer
         long_text_answer
         radio_answer
         checkbox_answers
         currency_answer
         number_answer
         single_date_answer]
    )
  end
end
