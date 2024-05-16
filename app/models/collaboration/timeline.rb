module Collaboration
  class Timeline < ApplicationRecord
    include Adjustable
    include Publishable

    has_many :stages, class_name: "Collaboration::TimelineStage", inverse_of: :timeline
    has_many :tasks, -> { order start_date: :asc }, class_name: "Collaboration::TimelineTask", through: :stages, source: :tasks
    belongs_to :case, class_name: "Support::Case", foreign_key: :support_case_id

    def self.create_default!(case:, start_date:)
      transaction do
        timeline = create_draft!(case:, start_date:, end_date: 1.business_days.after(start_date))
        timeline.stages.create_draft!(title: "Initial Stage: Start collaboration", stage: 0)
        timeline.stages.create_draft!(title: "Stage 1: Approach to market", stage: 1)
        timeline.stages.create_draft!(title: "Stage 2: Prepare and go to market", stage: 2)
        timeline.stages.create_draft!(title: "Stage 3: Decide", stage: 3)
        timeline.stages.create_draft!(title: "Stage 4: Award contract", stage: 4)
        timeline
      end
    end

    def tasks_after(task)
      tasks.where("start_date >= ?", task.end_date).order(start_date: :asc)
    end

    def tasks_before(task)
      tasks.where("end_date <= ?", task.start_date).reorder(end_date: :desc)
    end

    def task_after(task)
      tasks_after(task).first
    end

    def task_before(task)
      tasks_before(task).first
    end

    def refresh_end_date!
      self.end_date = stages.map(&:complete_by).compact.max
      save!
    end
  end
end
