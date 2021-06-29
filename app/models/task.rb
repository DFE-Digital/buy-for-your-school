# frozen_string_literal: true

# A Task belongs to a {Section} and consists of many {Step}s.
class Task < ApplicationRecord
  self.implicit_order_column = "created_at"

  belongs_to :section
  has_many :steps, dependent: :destroy

  validates :title, :contentful_id, presence: true

  before_save :tally_steps

  attr_accessor

  NOT_STARTED = 0
  IN_PROGRESS = 1
  COMPLETED = 2

  # Returns all visible steps.
  #
  # @return [Step::ActiveRecord_AssociationRelation]
  def visible_steps
    steps.where(hidden: false)
  end

  def has_single_visible_step?
    step_tally["visible"] == 1
  end

  # Returns the status of the current task.
  #
  # @return [Integer] {NOT_STARTED}, {IN_PROGRESS} or {COMPLETED}
  def status
    return COMPLETED if all_steps_answered?
    return IN_PROGRESS if step_tally["answered"].positive?

    NOT_STARTED
  end

  def all_steps_answered?
    step_tally["visible"] == step_tally["answered"]
  end

  # Returns all visible steps that have been answered.
  #
  # @return [Step::ActiveRecord_AssociationRelation]
  def visible_steps_with_answers
    eager_loaded_visible_steps.select(&:answered?)
  end

  # @return [String/Nil] `nil` if all steps are answered.
  def next_unanswered_step_id
    return nil if all_steps_answered?

    step_ids = eager_loaded_visible_steps.pluck(:id)
    answered_step_ids = visible_steps_with_answers.pluck(:id)
    remaining_ids = step_ids - answered_step_ids
    remaining_ids.first
  end

  # Returns all visible steps with eagerly-loaded answers.
  #
  # @return [Step::ActiveRecord_AssociationRelation]
  def eager_loaded_visible_steps
    visible_steps.includes(
      %i[short_text_answer
         long_text_answer
         radio_answer
         checkbox_answers
         currency_answer
         number_answer
         single_date_answer],
    ).ordered
  end

private

  # Returns a hash containing tallies of the steps on this task.
  #
  # Includes total, visible, hidden, and answered step tallies.
  #
  # @return [Hash<Symbol, Integer>]
  def tally_steps
    self.step_tally = {
      total: steps.count,
      visible: visible_steps.count,
      hidden: steps.where(hidden: true).count,
      answered: visible_steps_with_answers.count,
    }
  end
end
