module Frameworks::Activity
  extend ActiveSupport::Concern

  included do
    has_one :activity_log_item, as: :activity, touch: true
  end
end
