# A SupportRequest has and belongs to {User}
class SupportRequest < ApplicationRecord
  belongs_to :user
  accepts_nested_attributes_for :user

  belongs_to :school
  accepts_nested_attributes_for :school

  # validates :message, presence: true
end
