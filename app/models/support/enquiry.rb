# frozen_string_literal: true

# The support enquiry is the top-level entry into supported case management
# Support enquiries can come from multiple sources including but not limited to specify, email, hubs, email and phone.
module Support
  class Enquiry < ApplicationRecord
    include Support::Documentable

    belongs_to :case, class_name: "Support::Case", optional: true
  end
end
