#
# Chain of cummulatively validated steps to complete a "Support Request"
# using ActiveModel validations
#
# @see SupportRequest
#
class SupportForm
  include ActiveModel::Model

  attr_accessor :step

  STEPS = [1, 2, 3, 4].freeze

  def initialize(*)
    attr_accessors
    super
  end

  # @return [false, Integer]
  #
  def save
    return false unless valid?

    next_step
  end

  # @return [Integer]
  #
  def next_step
    @step = @step.to_i + 1
  end

  # @return [false]
  #
  def last_step?
    false
  end

  # @return [SupportRequest]
  #
  def support_request
    @support_request ||= SupportRequest.new(params.except(:step))
  end

  #
  # Confirm user's telephone number - not available from DSI
  #
  class Step1 < SupportForm
    # TODO: add validation for phone_number format
    validates :phone_number, presence: true
  end

  #
  # Select the specification document
  # Checklist of specs
  #
  class Step2 < Step1
    validates :journey_id, presence: true
  end

  #
  # Confirm the "category of spend"
  # "What are you buying?"
  #
  class Step3 < Step2
    validates :category_id, presence: true
  end

  #
  # "How can we help?"
  #
  class Step4 < Step3
    validates :message, presence: true
    validates :user, presence: true

    # @return [Boolean]
    #
    def save
      valid? && support_request.save!
    end

    # @return [true]
    #
    def last_step?
      true
    end
  end

private

  # @return [Array<Symbol>] strong params
  #
  def attributes
    %i[phone_number journey_id category_id message step user]
  end

  def attr_accessors
    attributes.each { |attr| class_eval { attr_accessor attr } }
  end

  def params
    attributes.index_with { |attr| send(attr) }.reject { |_, v| v.blank? }
  end
end
