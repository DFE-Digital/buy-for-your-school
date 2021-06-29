class CheckboxAnswers < ApplicationRecord
  include TaskCounters

  belongs_to :step

  validates :response,
            presence: true,
            unless: proc { |answer| answer.step.skippable? && answer.skipped }

  def response=(args)
    return if args.blank?

    args.reject!(&:blank?) if args.is_a?(Array)

    super(args)
  end
end
