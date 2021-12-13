# frozen_string_literal: true

module Support
  class ExistingContractPresenter < BasePresenter
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
    def ended_at
      return "-" unless super

      super.strftime("%e %B %Y")
    end
  end
end