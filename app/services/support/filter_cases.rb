# frozen_string_literal: true

module Support
  class FilterCases
    def filter(filtering_params)
      results = Case.preload(:organisation).includes(%i[agent category]).where.not(state: :closed)
      return results if filtering_params.nil?

      results = Case.preload(:organisation).includes(%i[agent category]).where(nil)

      filtering_params.each do |key, value|
        results = results.public_send("by_#{key}", value) if value.present?
      end

      results.order("ref DESC")
    end
  end
end
