# frozen_string_literal: true

module Support
  class NewContractPresenter < BasePresenter
    # @return [String]
    def spend
      super || "-"
    end

    # @return [String]
    def supplier
      super || "-"
    end

    # @return [String]
    def duration
      super || "-"
    end

    # @return [String]
    def started_at
      return "-" unless super

      super.strftime("%e %B %Y")
    end
  end
end