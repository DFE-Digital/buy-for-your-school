class Frameworks::ActivityEvent < ApplicationRecord
  include Frameworks::Activity

  def loaded_data
    OpenStruct.new(**data, **activity_log_item.subject.try(:activity_event_data_for, self).presence || {})
  end
end
