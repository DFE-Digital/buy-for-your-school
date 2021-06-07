# Dynamic date validation for SingleDateAnswer using JSON 'criteria' field.
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
# CATERING category
#   - When do you need the new catering service to start?   -> future
#   - When does your existing catering contract end?        -> future
#   - When was the kitchen last renovated, approximately?   -> past
#
# SPEC FIXTURES
#   - When will this start?                                 -> future
#   - When were you born?                                   -> past (new)
#
class DateValidator < ActiveModel::Validator
  def validate(record)
    # replace with #validation_criteria? method on the step
    return unless record.step.respond_to?(:raw)

    # replace with #validation_criteria method on the step
    fields = record.step.raw.fetch("fields", {})

    if (criteria = fields["criteria"])
      # range
      bounds = date_bounds(criteria["lower"], criteria["upper"])

      # validate
      record.errors.add(:response, criteria["message"]) unless bounds.cover?(record.response)
    end
  end

private

  # TODO: replace with persisted 'tstzrange'
  def date_bounds(lower, upper)
    Range.new(Time.zone.local(lower), Time.zone.local(upper))
  end
end
