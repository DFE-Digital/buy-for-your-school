# frozen_string_literal: true

module Support
  #
  # A public servant who picks up and handles "support cases"
  #
  class Agent < ApplicationRecord
    # has_one :profile

    has_many :cases, class_name: "Support::Case"
  end
end
