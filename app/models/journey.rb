# frozen_string_literal: true

# The top-level entity tracking user progress
# @see DashboardController#show
#
class Journey < ApplicationRecord
  self.implicit_order_column = "created_at"

  belongs_to :user
  belongs_to :category, counter_cache: true

  has_many :sections, dependent: :destroy
  has_many :tasks, through: :sections, class_name: "Task"
  has_many :steps, through: :tasks, class_name: "Step"

  # Automatic and User-defined flags
  # @see DeleteStaleJourneys
  #
  # initial (default)        - no actionable state
  # stale (automatic)        - unedited for a time
  # archive (user-defined)   - hide in dashboard
  # remove (user-defined)    - delete (permanent/soft)
  # finished (user-definied) - marked as 'finished'
  enum :state, { initial: 0, stale: 1, archive: 2, remove: 3, finished: 4 }

  # TODO: test scopes

  # default for new journeys
  scope :not_started, -> { where(started: false) }

  # when a step is completed a journey is considered started
  scope :started, -> { where(started: true) }

  # updated_at is after date
  scope :edited_since, ->(date) { where("updated_at > ?", date) }

  # updated_at is before date
  scope :unedited_since, ->(date) { where("updated_at < ?", date) }

  # Determine whether spec is a draft
  #
  # @see SpecificationsController#show
  #
  # @return [Boolean]
  def all_tasks_completed?
    tasks.all?(&:all_steps_completed?)
  end

  # Mark as started and revert state
  #
  # @see SaveAnswer
  #
  # @return [Boolean]
  def start!
    update!(started: true, state: :initial)
  end

  # Mark as finished and set state
  #
  # @return [Boolean]
  def finish!
    update!(finished_at: Time.zone.now, state: :finished)
  end

  # Next incomplete section in order, or first from beginning
  #
  # @param current_section [Section]
  #
  # @return [Section, Nil]
  def next_incomplete_section(current_section = nil)
    next_in_order = sections.includes([:tasks]).detect do |section|
      section.incomplete? && (section.order > current_section.order)
    end
    next_in_order || sections.detect(&:incomplete?)
  end

  # Advance through tasks and sections in order and loop at the end
  #
  # @param task [Task]
  #
  # @return [Task, Nil]
  def next_incomplete_task(task)
    return nil if all_tasks_completed?

    # current task
    if task.incomplete?
      task # same task

    # current section
    elsif task.section.incomplete?
      task.section.next_incomplete_task(task) # next task

    # next section
    elsif (next_section = next_incomplete_section(task.section))
      next_section.next_incomplete_task # first task
    end
  end

  # @return [Section]
  def sections_with_tasks
    sections.includes(:tasks)
  end
end
