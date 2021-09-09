# frozen_string_literal: true

module Support
  #
  # A "support enquiry" is the entry point into the "case management" facility.
  # Incoming enquiries will originate from the "self-serve API" (WIP),
  # or direct from the hubs via phone calls or emails.
  #
  class Enquiry < ApplicationRecord
    include Support::Documentable

    belongs_to :case, class_name: "Support::Case", optional: true
  end
end
