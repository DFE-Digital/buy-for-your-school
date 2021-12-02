# frozen_string_literal: true

module Support
  class NewContract < Contract
    has_one :support_case, class_name: "Support::Case"
  end
end
