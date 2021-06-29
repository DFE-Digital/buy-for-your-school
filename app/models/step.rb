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

  def answered?
    !answer.nil?
  end

  # Returns the text for the primary call-to-action button.
  # @see https://design-system.service.gov.uk/components/button/
  #
  # @return [String]
  def primary_call_to_action_text
    return I18n.t("generic.button.next") if super.blank?

    super
  end

  def skippable?
    skip_call_to_action_text.present?
  end

  # This method fetches the {Journey} associated to this step's {Task}'s {Section}.
  #
  # @return [Journey]
  def journey
    task.section.journey
  end

  # This method calls the owning {Task}'s save method to update its step tallies.
  #
  # This is used by the {TaskCounters} concern as a callback for when step answers
  # are committed.
  #
  # @return [Boolean]
  def update_task_counters
    task.save
  end
end
