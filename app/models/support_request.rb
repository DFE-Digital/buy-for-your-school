# frozen_string_literal: true

# A SupportRequest has and belongs to {User}
class SupportRequest < ApplicationRecord
  belongs_to :user

  validates :message, presence: true
end
