# Parse date fields as Dates
#
# Useful for extracting dates out of govuk_date_fields
module HasDateParams
  extend ActiveSupport::Concern

  # @param form_param [Symbol]
  # @param date_field [Symbol]
  #
  # @return [Hash]
  def date_param(form_param, date_field)
    date = params.fetch(form_param, {}).permit(
      "#{date_field}(1i)", # year
      "#{date_field}(2i)", # month
      "#{date_field}(3i)", # day
    )

    {
      day: date["#{date_field}(3i)"],
      month: normalize_month(date["#{date_field}(2i)"]),
      year: date["#{date_field}(1i)"],
    }
  end

  private

  def normalize_month(month)
    return if month.blank?

    month = month.to_s.strip
    return month.to_i if month.match?(/^\d+$/)

    # Full and abbreviated month names
    Date::MONTHNAMES.index(month.capitalize) || Date::ABBR_MONTHNAMES.index(month.capitalize)
  end
end
