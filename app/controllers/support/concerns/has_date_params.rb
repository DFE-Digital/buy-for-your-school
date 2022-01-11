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
      # @return [Hash]
      def date_param(form_param, date_field)
        date = params.require(form_param).permit(date_field)
        { day: date["#{date_field}(3i)"], month: date["#{date_field}(2i)"], year: date["#{date_field}(1i)"] }
      end

      def date_params(name)
        ["#{name}(1i)", "#{name}(2i)", "#{name}(3i)"].map(&:to_sym)
      end
    end
  end
end
