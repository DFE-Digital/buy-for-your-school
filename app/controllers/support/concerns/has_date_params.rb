# Parse date fields as Dates
#
# Useful for extracting dates out of govuk_date_fields
module Support
  module Concerns
    module HasDateParams
      extend ActiveSupport::Concern

      include DateHelper

      # @see DateHelper
      #
      # @param form_param [Symbol]
      # @param date_field [Symbol]
      #
      # @return [Date]
      def date_param(form_param, date_field)
        date = params.require(form_param).permit(date_field)
        date_hash = { day: date["#{date_field}(3i)"], month: date["#{date_field}(2i)"], year: date["#{date_field}(1i)"] }
        format_date(date_hash)
      end
    end
  end
end
