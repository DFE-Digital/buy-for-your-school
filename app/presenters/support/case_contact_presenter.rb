# frozen_string_literal: true

module Support
  class CaseContactPresenter < BasePresenter
    def first_name
      super.presence || "Sir"
    end

    def last_name
      if first_name == "Sir"
        "or Madam"
      else
        String(super)
      end
    end
  end
end
