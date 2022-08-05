# Dynamic validation for {SingleDateAnswer}, {NumberAnswer} and {CurrencyAnswer}
#
# @example
#   ContentfulType: Question
#   "fields": {
#     "type": "single_date"
#     "criteria": {
#       "upper": "",
#       "lower": "",
#       "message": "out of bounds"
#     }
#   }
#
class RangeValidator < ActiveModel::Validator
  # @param record [Mixed] answer types
  #
  # @return [Nil, ActiveModel::Error]
  def validate(record)
    # model specs don't bother building the step
    return unless record.step&.criteria?

    criteria = record.step.criteria.with_indifferent_access

    bounds = range(
      type: record.step.contentful_type,
      lower: criteria[:lower],
      upper: criteria[:upper],
    )

    record.errors.add(:response, criteria[:message]) unless bounds.cover?(record.response)
  end

private

  # @param type [String]
  # @param lower [String]
  # @param upper [String]
  #
  # @return [Range]
  def range(type:, lower:, upper:)
    case type
    when "single_date"
      Range.new(Time.zone.parse(lower), Time.zone.parse(upper))
    when "number"
      Range.new(lower.to_i, upper.to_i)
    when "currency"
      Range.new(lower.to_f, upper.to_f)
    end
  end
end
