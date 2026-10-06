class Energy::RegisterYourInterestForm < Energy::Form
private

  def parsed_contract_end_date(raw)
    return [nil, false] if raw.blank?
    return [raw, false] if raw.is_a?(Date)

    parts = {
      year: raw[1] || raw["year"] || raw[:year],
      month: raw[2] || raw["month"] || raw[:month],
      day: raw[3] || raw["day"] || raw[:day],
    }
    return [nil, false] if parts.values.all?(&:blank?)
    return [nil, true] if parts.values.any?(&:blank?)

    year = Integer(parts[:year], 10)
    month = Integer(parts[:month].to_s, 10)
    day = Integer(parts[:day], 10)
    return [nil, true] unless Date.valid_date?(year, month, day)

    [Date.new(year, month, day), false]
  rescue ArgumentError, TypeError
    [nil, true]
  end

  def date_within_range?(date)
    date > Date.current.advance(years: -5) &&
      date < Date.current.advance(years: 5)
  end
end
