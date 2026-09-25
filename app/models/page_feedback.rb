# app/models/page_feedback.rb
class PageFeedback < ApplicationRecord
  validates :page_url, presence: true
  validates :page_useful, inclusion: { in: [true, false] }
  validates :feedback, length: { maximum: 250 }
end
