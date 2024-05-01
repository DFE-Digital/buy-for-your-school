module Collaboration
  class Timeline < ApplicationRecord
    include Adjustable

    has_many :stages, class_name: "Collaboration::TimelineStage"
    has_many :tasks, -> { order start_date: :asc }, class_name: "Collaboration::TimelineTask", through: :stages, source: :tasks
    belongs_to :case, class_name: "Support::Case", foreign_key: :support_case_id

    def self.create_demo!(case:, start_date:)
      transaction do
        timeline = create!(case:, start_date:)
        stage_0 = timeline.stages.create!(title: "Initial Stage: Start collaboration", stage: 0)
        stage_0.tasks.create!(title: "Task 1", duration: 2.days)
        stage_0.tasks.create!(title: "Task 2", duration: 5.days)
        stage_1 = timeline.stages.create!(title: "Stage 1: Approach to market", stage: 1)
        stage_1.tasks.create!(title: "Task 1", duration: 3.days)
        stage_1.tasks.create!(title: "Task 2", duration: 10.days)
        stage_2 = timeline.stages.create!(title: "Stage 2: Prepare and go to market", stage: 2)
        stage_2.tasks.create!(title: "Task 1", duration: 14.days)
        stage_2.tasks.create!(title: "Task 2", duration: 20.days)
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
      self.end_date = stages.last.complete_by
      save!
    end
  end
end
