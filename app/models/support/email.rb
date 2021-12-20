module Support
  class Email < ApplicationRecord
    belongs_to :case, class_name: "Support::Case", optional: true

    scope :display_order, -> { order("sent_at DESC") }
  end
end
