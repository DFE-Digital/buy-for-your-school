# This module is used on {Step} answers (e.g. {NumberAnswer}) to update {Task} tallies.
#
# @see Step#update_task_counters
# @see Task#tally_steps
module TaskCounters
  extend ActiveSupport::Concern
  included do
    after_commit :update_task_counters

  private

    def update_task_counters
      step.update_task_counters
    end
  end
end
