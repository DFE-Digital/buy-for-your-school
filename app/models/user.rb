# A User may have many {Journey}s.
# A User may have many Support Request(s)
class User < ApplicationRecord
  # TODO: rename User to Profile but don't change the table name yet
  # self.table_name = "users"

  # TODO: move journeys association to a new entity with SupportRequests
  has_many :journeys

  def guest?
    false
  end

  has_many :support_requests, class_name: "SupportRequest"
  accepts_nested_attributes_for :support_requests
end
