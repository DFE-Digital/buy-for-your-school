# frozen_string_literal: true

# Date coercion helpers
#
# @see AnswersController#date_params
#
module DateHelper
  # Convert a hash with `day`, `month` and `year` values into a Date.
  #
  # @param params [Hash<Symbol, String>]
  #
  # @return [Date, nil]
  def format_date(params)
    date_parts = params.values_at(:day, :month, :year)
    return unless date_parts.all?(&:present?)

    day, month, year = date_parts.map(&:to_i)
    Date.new(year, month, day)
  rescue ArgumentError
    nil
  end
end
