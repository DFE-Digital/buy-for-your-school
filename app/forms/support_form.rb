#
# Chain of cummulatively validated steps to complete a "Support Request"
# using ActiveModel validations
#
# @see SupportRequest
#
class SupportForm

  # def self.build(step = 0, params = {})
  #   "SupportForm::Step#{step}".constantize.new(step: step.to_i, **params)
  # end

  include ActiveModel::Model

  attr_accessor :step

  # form params
  attr_accessor :phone_number # step 1
  attr_accessor :journey_id   # step 2
  attr_accessor :category_id  # step 3
  attr_accessor :message      # step 4

  def position
    # return @step.to_i unless @step.nil?
    # 1
    self.class.name.match(/(\d)/)[0].to_i
  end


  # def next_step
  #   position + 1
  # end

  # @param phone_number
  # @param journey_id
  # @param category_id
  # @param message
  # @param user
  # @param step [Integer] defaults to 1
  #
  def initialize(*)
    attr_accessors
    super
  end



  # @return [Array<Symbol>] strong params
  #
  def attributes
    %i[phone_number journey_id category_id message step]
  end


  # def proceed
  #   next_step! unless last_step?
  # end

  # Validate then proceed or save
  #
  # @return [Boolean, Integer]
  #
  # def save
  #   if last_step?
  #     valid? ? support_request.save! : false
  #   else
  #     valid? ? next_step! : false
  #     # valid? ? next_step : false
  #   end
  # end

  # @return [Integer] increment the step counter
  #
  def increment!
    @step = @step.to_i + 1
    # @position = @position.to_i + 1
  end

  # # @return [Integer] decrement the step counter
  # #
  # def previous_step!
  #   @step = @step.to_i - 1
  # end

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


# private

  # def attr_accessors
  #   attributes.each { |attr| class_eval { attr_accessor attr } }
  # end

  # @return [Hash] retrieve the values for all the attributes
  #
  # @example
  #   { phone_number: "1234567890", step: 3 }
  #
  def params
    attributes.index_with { |attr| send(attr) }.reject { |_, v| v.blank? }
  end

  #
  # Confirm user's telephone number - not available from DSI
  #
  class Step1 < SupportForm
    validates :phone_number,
      presence: true,
      numericality: true,
      length: {
        minimum: 10,
        maximum: 11
      }

  end

  #
  # Select the specification document
  #
  class Step2 < Step1
    validates :journey_id, presence: true


    def checked?(category)
      support_request.has_journey? && category.has_journey?(journey_id)
    end
  end

  #
  # Confirm the "category of spend"
  # "What are you buying?"
  #
  class Step3 < Step2
    validates :category_id, presence: true

    # def checked?(category)
    #   support_request.has_journey? && category.has_journey?(journey_id)
    # end
  end

  #
  # "How can we help?"
  #
  class Step4 < Step3
    validates :message,
      presence: true,
      length: {
        minimum: 20
      }

    # @return [true]
    #
    def last_step?
      true
    end
  end

end
