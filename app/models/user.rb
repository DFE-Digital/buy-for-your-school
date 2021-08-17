# A User may have many {Journey}s.
# A User may have many Support Request(s)
# A User may have many School(s) through SchoolUsers
class User < ApplicationRecord
  has_many :journeys
  has_many :support_requests
  has_many :school_users
  has_many :schools, through: :school_users
end
