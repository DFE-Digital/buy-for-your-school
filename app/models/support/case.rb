# frozen_string_literal: true

module Support
  #
  # A case is opened from a "support enquiry" dealing with a "category of spend"
  #
  class Case < ApplicationRecord
    include Documentable

    has_one :enquiry, class_name: "Support::Enquiry"
    belongs_to :category, class_name: "Support::Category", optional: true
    belongs_to :agent, class_name: "Support::Agent", optional: true
    has_many :interactions, class_name: "Support::Interaction"

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

    # do we still need the request text attr as all cases should have an enquiry as entry point
    delegate :message, to: :enquiry

    before_validation :generate_ref
    validates :ref, uniqueness: true, length: { is: 6 }, format: { with: /\A\d+\z/, message: "numbers only" }

    # Called before validation to assign 6 digit incremental number (from last case or the default 000000)
    # @return [String]
    def generate_ref
      self.ref = (Support::Case.last&.ref || sprintf("%06d", 0)).next
    end

    # TODO: Replace with ActiveRecord association
    # This is going to be renamed to "Buyer" and represents the
    # School (SBP) that case workers interact with via cases.
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
