# frozen_string_literal: true

module Support
  #
  # An existing contract between a school and an organisation
  #
  class ExistingContract < Contract
    has_one :support_case, class_name: "Support::Case"
  end
end
