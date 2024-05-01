module Support::Case::Timelineable
  extend ActiveSupport::Concern

  included do
    has_many :timelines, class_name: "Collaboration::Timeline", foreign_key: :support_case_id
  end

  def latest_timeline
    timelines.last
  end
end
