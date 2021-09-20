# frozen_string_literal: true

module Support
  class Interaction < ApplicationRecord
    belongs_to :agent, class_name: "Support::Agent", optional: true

    # Type
    #
    #   note (default)
    #   phone_call
    #   email_from_school
    #   email_to_school
    enum type: { note: 0, phone_call: 1, email_from_school: 2, email_to_school: 3 }

    validates :body, presence: true
  end
end
