class CheckboxAnswers < ActiveRecord::Base
  self.implicit_order_column = "created_at"
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
