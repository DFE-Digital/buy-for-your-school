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
    visible_steps.includes([
      :short_text_answer,
      :long_text_answer,
      :radio_answer,
      :checkbox_answers,
      :currency_answer,
      :number_answer,
      :single_date_answer
    ]).count { |step| step.answered? }
  end

  def status
    if answered_questions_count == visible_steps_count
      return COMPLETED
    end

    if answered_questions_count > 0
      return IN_PROGRESS
    end

    NOT_STARTED
  end
end
