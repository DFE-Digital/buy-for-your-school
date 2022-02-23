class FrameworkRequest < ApplicationRecord
  validates :first_name, :last_name, :email, :message_body, presence: true

  belongs_to :user, optional: true
end
