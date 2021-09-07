# frozen_string_literal: true

# The support enquiry is the top-level entry into supported case management
# Support::Enquiry belongs Support::Cases
module Support
  class Enquiry < ApplicationRecord
    include Support::Documentable

    belongs_to :case, class_name: "Support::Case", optional: true
  end
end
