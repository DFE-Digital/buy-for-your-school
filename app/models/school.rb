# frozen_string_literal: true

# A School has and belongs to many {User}
class School < ApplicationRecord
  has_and_belongs_to_many :users
end
