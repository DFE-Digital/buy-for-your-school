# frozen_string_literal: true

module Support
  class FrameworkPresenter < BasePresenter
    # @return [String] "26 November 2021" or "-"
    def expires_at
      super ? super.strftime(date_format) : "-"
    end

    # Include formatted 'expires_at' in the JSON representation
    #
    # @see Support::FrameworksController
    #
    # @return [Hash]
    def as_json(options = {})
      super(options).merge({
        "expires_at" => expires_at,
      })
    end
  end
end
