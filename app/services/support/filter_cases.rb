# frozen_string_literal: true

module Support
  class FilterCases
    attr_reader :base_cases

    def initialize(base_cases: nil) = @base_cases = base_cases || Case

    def filter(filtering_params)
      results = base_cases.preload(:organisation).includes(%i[agent category])

      return results if filtering_params.nil?

      filtering_params.each do |key, value|
        results = results.public_send("by_#{key}", value) if value.to_s.present?
      end

      results
    end
  end
end
