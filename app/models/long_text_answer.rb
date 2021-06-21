class LongTextAnswer < ActiveRecord::Base
  self.implicit_order_column = "created_at"
  belongs_to :step

  validates :response, presence: true

  after_commit :update_task_counters

  private def update_task_counters
    step.update_task_counters
  end
end
