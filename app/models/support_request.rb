# A SupportRequest has and belongs to {User}
class SupportRequest < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true
  belongs_to :journey, optional: true
end
