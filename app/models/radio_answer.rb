# RadioAnswer is used to capture a radio button answer to a {Step}.
class RadioAnswer < ApplicationRecord
  include TaskCounters

  belongs_to :step

  validates :response, presence: true
end
