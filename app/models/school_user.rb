# Belongs to School
# Belongs to User
class SchoolUser < ApplicationRecord
  belongs_to :school
  belongs_to :user
end
