# NumberAnswer is used to capture a number answer to a {Step}.
class NumberAnswer < ApplicationRecord
  include TaskCounters

  belongs_to :step

  validates :response,
            presence: true,
            numericality: {
              only_integer: true,
            }
end
