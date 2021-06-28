# frozen_string_literal: true

# A Journey belongs to a {User} and consists of {Section}s.
class Journey < ApplicationRecord
  self.implicit_order_column = "created_at"

  belongs_to :user
  belongs_to :category, counter_cache: true

  has_many :sections, dependent: :destroy
  has_many :tasks, through: :sections, class_name: "Task"
  has_many :steps, through: :tasks, class_name: "Step"

  # initial - the initial state all Journeys are in
  # stale - automatic flag for Journeys that have not been touched for a while and could be purged
  # archive - user-defined flag so it may be hidden from their dashboard
  # remove - user-defined flag so it can be safely deleted (soft delete)
  enum state: { initial: 0, stale: 1, archive: 2, remove: 3 }

  # Determine whether spec is a draft
  #
  # @see SpecificationsController#show
  #
  def all_tasks_completed?
    tasks.all?(&:all_steps_completed?)
  end

  # Updates the state to indicate that a journey has been started.
  #
  # This ensures started journeys are not removed during automated clean up.
  #
  # @return [Boolean]
  def freshen!
    attributes = {}
    attributes[:started] = true unless started == true

    update!(attributes)
  end
end
