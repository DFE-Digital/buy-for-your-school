# A User has many {Journey}s
#
class User < ApplicationRecord
  # TODO: rename User to Profile but don't change the table name yet
  # self.table_name = "users"

  # TODO: move journeys association to a new entity with SupportRequests
  has_many :journeys

  def guest?
    false
  end
end
