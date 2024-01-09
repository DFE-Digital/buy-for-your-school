# frozen_string_literal: true

# A Task belongs to a {Section} and has many {Step}s
class Task < ApplicationRecord
  self.implicit_order_column = "order"

  default_scope { order(:order) }

  belongs_to :section

  has_many :steps, dependent: :destroy

  validates :title, :contentful_id, presence: true

  before_save :tally_steps

  NOT_STARTED = 0
  IN_PROGRESS = 1
  COMPLETED = 2

  # Use tally to infer state
  #
  # @return [Integer] 0, 1, 2
  def status
    return COMPLETED if all_steps_completed?
    return IN_PROGRESS if tally_for(:completed).positive?

    NOT_STARTED
  end

  # @param key [Symbol, String] step_tally key
  #
  # @return [Integer]
  def tally_for(key)
    step_tally.fetch(key.to_s, 0)
  end

  # Use tally to infer state
  #
  # @return [Boolean]
  def has_single_visible_step?
    tally_for(:visible) == 1
  end

  # @return [Boolean]
  def incomplete?
    !all_steps_completed?
  end

  # Use tally to infer state - visible steps vs. completed
  #
  # @return [Boolean]
  def all_steps_completed?
    tally_for(:visible) == tally_for(:completed)
  end

  # Use tally to infer state - visible questions vs. answered
  #
  # @return [Boolean]
  def all_questions_answered?
    tally_for(:questions) == tally_for(:answered)
  end

  # Use tally to infer state - visible statements vs. acknowledged
  #
  # @return [Boolean]
  def all_statements_acknowledged?
    tally_for(:statements) == tally_for(:acknowledged)
  end

  # Use tally to infer state - visible unanswered questions vs. skipped
  #
  # @return [Boolean]
  def all_unanswered_questions_skipped?
    (tally_for(:questions) - tally_for(:answered)) == tally_for(:skipped)
  end

  def visible_questions_with_answers
    eager_loaded_visible_steps.that_are_questions.select(&:answered?)
  end

  def visible_statements_acknowledged
    steps.visible.that_are_statements.where(id: statement_ids.to_a)
  end

  def completed_steps
    visible_questions_with_answers + visible_statements_acknowledged
  end

  # @return [String, Nil]
  def next_incomplete_step_id
    return nil if all_steps_completed?

    step_ids = eager_loaded_visible_steps.pluck(:id)
    answered_question_ids = visible_questions_with_answers.pluck(:id)

    remaining_ids = step_ids - answered_question_ids - statement_ids - skipped_ids.to_a
    remaining_ids.concat(skipped_ids)
    remaining_ids.first
  end

  # @return [Step::ActiveRecord_AssociationRelation]
  def eager_loaded_visible_steps
    steps.visible.includes(
      %i[
        short_text_answer
        long_text_answer
        radio_answer
        checkbox_answers
        currency_answer
        number_answer
        single_date_answer
        task
      ],
    ).ordered
  end

  # Return the next skipped ID relative to the provided one
  #
  # @param [String] current_id
  #
  # @return [Nil, String]
  def next_skipped_id(current_id)
    index = skipped_ids.index(current_id)
    skipped_ids.rotate(index)[1]
  end

private

  # Calculates tallies of the steps on this task
  #
  # @return [Nil, Hash<Symbol, Integer>]
  def tally_steps
    visible_steps = steps.visible

    self.step_tally = {
      visible: visible_steps.count,                                 # visible steps
      hidden: steps.hidden.count,                                   # hidden steps
      total: steps.count,                                           # all steps
      completed: completed_steps.count,                             # visible completed steps
      statements: visible_steps.that_are_statements.count,          # visible statement steps
      acknowledged: statement_ids.count,                            # visible completed statement steps
      questions: visible_steps.that_are_questions.count,            # visible question steps
      answered: visible_questions_with_answers.count,               # visible completed question steps
      # TODO: check to be removed; this is for migration tests that rollback to a schema without skipped_ids
      skipped: (skipped_ids.count if respond_to?(:skipped_ids)), # visible skipped question steps
    }
  end
end
