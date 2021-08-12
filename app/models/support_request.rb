class SupportRequest < ApplicationRecord
  belongs_to :user

  validates :message, presence: true
end
