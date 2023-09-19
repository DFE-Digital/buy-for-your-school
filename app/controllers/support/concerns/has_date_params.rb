# Parse date fields as Dates
#
# Useful for extracting dates out of govuk_date_fields
module Support
  module Concerns
    module HasDateParams
      extend ActiveSupport::Concern

      # @param form_param [Symbol]
      # @param date_field [Symbol]
      #
      # @return [Hash]
      def date_param(form_param, date_field)
        date = params.fetch(form_param, {}).permit(date_field)
        { day: date["#{date_field}(3i)"], month: date["#{date_field}(2i)"], year: date["#{date_field}(1i)"] }
      end
    end
  end
end
