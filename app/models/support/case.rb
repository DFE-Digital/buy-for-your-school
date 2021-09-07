# frozen_string_literal: true

# The top-level entity tracking cases
# Support::Case has one Support::Enquiry
# Support::Case belongs_to Support::Category

module Support
  class Case < ApplicationRecord
    include Support::Documentable

    has_one :enquiry, class_name: "Support::Enquiry"
    belongs_to :category, class_name: "Support::Category"

    # User-defined support levels
    #
    # L1       - Advice and guidance only
    # L2       - Pointing to a framework / catalogue
    # L3       - Helping school run a framework but school doing system work
    # L4       - Run framework on behalf of school
    # L5       - Run bespoke procurement
    enum support_level: { L1: 0, L2: 1, L3: 2, L4: 3, L5: 4 }

    # User-defined state
    #
    # initial (default)
    # open
    # resolved
    # pending
    # closed
    # pipeline
    # no_response
    enum state: { initial: 0, open: 1, resolved: 2, pending: 3, closed: 4, pipeline: 5, no_response: 6 }
  end
end
