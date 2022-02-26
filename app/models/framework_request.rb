class FrameworkRequest < ApplicationRecord
  belongs_to :user, optional: true

  # validates :first_name, :last_name, :email, :message_body, presence: true
end
