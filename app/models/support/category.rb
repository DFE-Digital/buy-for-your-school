# frozen_string_literal: true

# The support category that a support case belongs to
# Support::Category has_many Support::Cases
module Support
  class Category < ApplicationRecord
    has_many :cases, class_name: "Support::Case"

    validates :name, presence: true
  end
end
