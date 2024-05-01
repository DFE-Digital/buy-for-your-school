module Support
  class TimelineStage < ApplicationRecord
    # has_paper_trail ignore: %i[id created_at updated_at]

    has_many :tasks, -> { order start_date: :asc }, class_name: "Support::TimelineTask", foreign_key: :support_timeline_stage_id
    belongs_to :timeline, class_name: "Support::Timeline", foreign_key: :support_timeline_id

    after_save :update_timeline_end_date

    default_scope { order(stage: :asc) }

    def stage_title
      "Stage #{stage}"
    end

    def stage_shorthand
      "S#{stage}"
    end

    def refresh_complete_by!
      self.complete_by = tasks.last.end_date
      save!
    end

  private

    def update_timeline_end_date
      last_stage = timeline.stages.last
      timeline.refresh_end_date! if timeline.end_date != last_stage.complete_by
    end
  end
end
