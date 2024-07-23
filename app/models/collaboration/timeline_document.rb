module Collaboration
  class TimelineDocument < ApplicationRecord
    include SharepointIntegratable

    belongs_to :task, class_name: "Collaboration::TimelineTask", foreign_key: :timeline_task_id

    enum permissions: { none: 0, read: 1, read_write: 2 }, _prefix: true
  end
end
