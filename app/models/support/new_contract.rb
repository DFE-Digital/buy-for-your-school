# frozen_string_literal: true

module Support
  #
  # A (potential) new contract between a school and an organisation
  #
  class NewContract < Contract
    has_one :support_case, class_name: "Support::Case"
  end
end
