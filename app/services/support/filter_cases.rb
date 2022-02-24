# frozen_string_literal: true

module Support
  class FilterCases
    def filter(filtering_params)
      results = Case.includes(%i[agent category organisation]).where(nil)

      return results if filtering_params.nil?

      filtering_params.each do |key, value|
        results = results.public_send("by_#{key}", value) if value.present?
      end
      results
    end
  end
end
