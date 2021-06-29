# ShortTextAnswer is used to capture a short text answer to a {Step}.
class ShortTextAnswer < ApplicationRecord
  include TaskCounters

  belongs_to :step

  validates :response, presence: true
end
