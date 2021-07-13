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
  # initial (default)       - no actionable state
  # stale (automatic)       - unedited for a time
  # archive (user-defined)  - hide in dashboard
  # remove (user-defined)   - delete (permanent/soft)
  enum state: { initial: 0, stale: 1, archive: 2, remove: 3 }

  # Determine whether spec is a draft
  #
  # @see SpecificationsController#show
  #
  # @return [Boolean]
  def all_tasks_completed?
    tasks.all?(&:all_steps_completed?)
  end

  # Mark as started once a step has been completed.
  # @see SaveAnswer
  #
  # @return [Boolean]
  def start!
    attributes = {}
    attributes[:started] = true unless started == true

    update!(attributes)
  end
end
