# frozen_string_literal: true

module Support
  #
  # A case is opened from a "support enquiry" dealing with a "category of spend"
  #
  class Case < ApplicationRecord
    include Support::Documentable

    has_one :enquiry, class_name: "Support::Enquiry"
    belongs_to :category, class_name: "Support::Category"

    # Support level
    #
    #   L1       - Advice and guidance only
    #   L2       - Pointing to a framework / catalogue
    #   L3       - Helping school run a framework but school doing system work
    #   L4       - Run framework on behalf of school
    #   L5       - Run bespoke procurement
    enum support_level: { L1: 0, L2: 1, L3: 2, L4: 3, L5: 4 }

    # State
    #
    #   initial (default)
    #   open
    #   resolved
    #   pending
    #   closed
    #   pipeline
    #   no_response
    enum state: { initial: 0, open: 1, resolved: 2, pending: 3, closed: 4, pipeline: 5, no_response: 6 }

    # TODO: Replace with ActiveRecord association
    def interactions
      time = Time.zone.local(2020, 1, 30, 12)
      [
        OpenStruct.new(
          id: 1,
          author: "Example Author",
          type: "Phone",
          note: "Example ticket note",
          created_at: time,
          updated_at: time,
        ),
      ]
    end

    # TODO: Replace with ActiveRecord association
    def case_worker_account
      OpenStruct.new(full_name: "Example Agent")
    end

    # TODO: Replace with ActiveRecord association
    def contact
      OpenStruct.new(
        first_name: "Example First",
        last_name: "Name",
        phone_number: "+44 777888999",
        email_address: "example@email.com",
      )
    end
  end
end
