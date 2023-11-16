class Frameworks::ActivityEvent < ApplicationRecord
  include Frameworks::Activity

  scope :added_notes, ->(subject) { joins(:activity_log_item).where(event: "note_added", activity_log_item: { subject: }) }

  def loaded_data
    OpenStruct.new(**data, **activity_log_item.subject.try(:activity_event_data_for, self).presence || {})
  end

  def activity_log_event_description
    event
  end
end
