module Collaboration
  class TimelineStage < ApplicationRecord
    include Publishable

    has_many :tasks, -> { order start_date: :asc }, class_name: "Collaboration::TimelineTask", foreign_key: :timeline_stage_id, inverse_of: :stage
    belongs_to :timeline, class_name: "Collaboration::Timeline", inverse_of: :stages

    after_save :update_timeline_end_date, if: -> { complete_by.present? }

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
