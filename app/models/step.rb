# frozen_string_literal: true

# A Step belongs to a {Task} and may have one of
# {RadioAnswer}, {ShortTextAnswer}, {LongTextAnswer}, {SingleDateAnswer}, {CheckboxAnswers}, {NumberAnswer}, {CurrencyAnswer}.
class Step < ApplicationRecord
  self.implicit_order_column = "order"

  belongs_to :task

  has_one :radio_answer
  has_one :short_text_answer
  has_one :long_text_answer
  has_one :single_date_answer
  has_one :checkbox_answers
  has_one :number_answer
  has_one :currency_answer

  scope :that_are_questions, -> { where(contentful_model: "question") }
  scope :that_are_statements, -> { where(contentful_model: "statement") }

  scope :visible, -> { where(hidden: false) }
  scope :hidden, -> { where(hidden: true) }

  scope :ordered, -> { order(:order) }

  after_save :update_task_counters

  # Returns the answer to this step.
  #
  # @return [Mixed]
  def answer
    @answer ||=
      case contentful_type
      when "radios" then radio_answer
      when "short_text" then short_text_answer
      when "long_text" then long_text_answer
      when "single_date" then single_date_answer
      when "checkboxes" then checkbox_answers
      when "number" then number_answer
      when "currency" then currency_answer
      end
  end

  # @return [Boolean]
  def answered?
    !answer.nil?
  end

  # @return [Boolean]
  def acknowledged?
    task.statement_ids.include?(id)
  end

  # @return [Boolean]
  def completed?
    answered? || acknowledged?
  end

  # Record step UUID confirming statement as read
  #
  # @return [Boolean]
  def acknowledge!
    task.statement_ids << id
    task.save!
  end

  # Button text to advance through steps
  #
  # @see https://design-system.service.gov.uk/components/button/
  #
  # @return [String]
  def primary_call_to_action_text
    super || I18n.t("generic.button.next")
  end

  # TODO: rename this
  # @return [Boolean]
  def skippable?
    skip_call_to_action_text.present?
  end

  # @return [Journey]
  def journey
    task.section.journey
  end

  # Trigger Task#tally_steps callback to refresh `Task.step_tally`
  #
  # @see {TaskCounters} concern
  #
  # @return [Boolean]
  def update_task_counters
    task.save
  end
end
