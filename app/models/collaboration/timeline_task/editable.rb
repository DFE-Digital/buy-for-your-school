module Collaboration::TimelineTask::Editable
  extend ActiveSupport::Concern

  def editor(params = editor_defaults)
    Collaboration::TimelineTask::Editor.new(timeline_task: self, **params)
  end

  def edit(details)
    update!(details)
  end

private

  def editor_defaults
    {
      title:,
      timeframe_type: :date_range,
      start_date:,
      end_date:,
      duration: duration_int,
    }
  end
end
