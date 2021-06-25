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
