# frozen_string_literal: true

# Date coercion helpers
#
# @see AnswersController#date_params
#
module DateHelper
  include ActionView::Helpers::DateHelper
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

  def simple_distance_of_time_in_words(from_time, to_time = 0, options = {})
    options = {
      scope: :'datetime.distance_in_words',
    }.merge!(options)

    orig_from_time = from_time
    orig_to_time   = to_time

    from_time = normalize_distance_of_time_argument_to_time(from_time)
    to_time = normalize_distance_of_time_argument_to_time(to_time)
    from_time, to_time = to_time, from_time if from_time > to_time
    distance_in_minutes = ((to_time - from_time) / 60.0).round
    distance_in_seconds = (to_time - from_time).round

    I18n.with_options locale: options[:locale], scope: options[:scope] do |locale|
      case distance_in_minutes
      # up to a minute
      when 0
        case distance_in_seconds
        when 0..30 then locale.t :just_now
        else
          locale.t :about_x_minutes, count: 1
        end

      # up to an hour
      when 1...60 then locale.t :x_minutes, count: distance_in_minutes

      # up to a day
      when 60..1440 then locale.t :x_hours, count: (distance_in_minutes.to_f / 60.0).round

      # up to a month
      when 1440..43_200 then locale.t :x_days, count: (distance_in_minutes.to_f / 1440.0).round

      # up to a year
      when 43_200..525_600 then locale.t :x_months, count: (distance_in_minutes.to_f / 43_200.0).round

      # other
      else
        distance_of_time_in_words(orig_from_time, orig_to_time, options)
      end
    end
  end

  def relative_date_format(date)
    date = normalize_distance_of_time_argument_to_time(date)
    return short_date_format(date, show_time: false) if date.to_date != Date.current

    "#{simple_distance_of_time_in_words(date, Time.zone.now)} ago"
  end

  def short_date_format(date, show_time: true, always_show_year: false)
    date = normalize_distance_of_time_argument_to_time(date)
    year_directive = always_show_year || date.year != Time.zone.now.year ? " %Y" : ""
    time_directive = show_time ? " %H:%M" : ""

    date.strftime("%d %b#{year_directive}#{time_directive}")
  end
end
