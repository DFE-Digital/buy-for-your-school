# A School may have many User(s) through SchoolUsers
class School < ApplicationRecord
  has_many :school_users
  has_many :users, through: :school_users
end
