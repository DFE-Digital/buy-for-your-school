# LongTextAnswer is used to capture a long text answer to a {Step}.
class LongTextAnswer < ApplicationRecord
  include TaskCounters

  belongs_to :step

  validates :response, presence: true
end
