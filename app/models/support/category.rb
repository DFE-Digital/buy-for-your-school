module Support
  class Category < ApplicationRecord
    has_many :cases, class_name: "Support::Case"

    validates :name, presence: true
  end
end
