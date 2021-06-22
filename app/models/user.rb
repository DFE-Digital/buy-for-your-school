# A User may have many {Journey}s.
class User < ApplicationRecord
  has_many :journeys
end
