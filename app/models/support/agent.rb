module Support
  class Agent < ApplicationRecord
    # has_one :profile

    has_many :cases, class_name: "Support::Case"
  end
end
