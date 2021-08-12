# A User may have many {Journey}s.
class User < ApplicationRecord
  has_many :journeys
  has_many :support_requests
  has_and_belongs_to_many :schools
end
