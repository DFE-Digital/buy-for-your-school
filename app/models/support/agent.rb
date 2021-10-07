# frozen_string_literal: true

module Support
  #
  # A public servant who picks up and handles "support cases". This is sometimes
  # referred to as "worker", "case worker" or "proc ops worker" within the business.
  #
  class Agent < ApplicationRecord
    has_many :cases, class_name: "Support::Case"
  end
end
