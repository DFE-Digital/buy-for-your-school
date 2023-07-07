# frozen_string_literal: true

module Support
  class FilterCases
    attr_reader :base_cases

    attr_accessor :included_associations

    def initialize(base_cases: nil) = @base_cases = base_cases || Case

    def filter(filtering_params)
      results = base_cases.preload(:organisation).includes(associations)

      return results if filtering_params.nil?

      filtering_params.each do |key, value|
        if key == :tower && value == "no-tower"
          results = results.without_tower
        elsif value.to_s.present?
          results = results.public_send("by_#{key}", value)
        end
      end

      results
    end

  private

    def associations
      @included_associations || %i[agent category]
    end
  end
end
