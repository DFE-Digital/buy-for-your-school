module Collaboration::Timeline::Adjustable
  extend ActiveSupport::Concern

  def adjustor_by_updated_task(task:, new_start_date:, new_end_date:)
    Collaboration::Timeline::Adjustor.by_updated_task(timeline: self, task:, new_start_date:, new_end_date:)
  end

  def adjustor_by_new_task(task:, new_start_date:, new_end_date:)
    Collaboration::Timeline::Adjustor.by_new_task(timeline: self, task:, new_start_date:, new_end_date:)
  end
end
