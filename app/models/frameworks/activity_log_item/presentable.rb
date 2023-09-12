module Frameworks::ActivityLogItem::Presentable
  extend ActiveSupport::Concern

  def display_created_at
    created_at.strftime("%d/%m/%Y %H:%M:%S")
  end

  def display_actor
    actor.try(:full_name)
  end
end
