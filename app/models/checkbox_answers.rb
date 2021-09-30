# CheckboxAnswers is used to capture a checkbox value answer to a {Step}.
class CheckboxAnswers < ApplicationRecord
  include TaskCounters

  belongs_to :step

  validates :response,
            presence: true,
            unless: proc { |answer| answer.step.skippable? && answer.skipped }

  # Ensure no blank checkbox values are set
  #
  # @param [Array] args
  #
  # @return [Array, nil] array of answers or nil.
  def response=(args)
    return if args.blank?

    args.reject!(&:blank?) if args.is_a?(Array)

    super(args)
  end
end
