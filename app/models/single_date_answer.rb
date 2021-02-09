class SingleDateAnswer < ActiveRecord::Base
  # attr_accessor :response

  self.implicit_order_column = "created_at"
  belongs_to :step

  # validate :validate_no_setter_errors
  validates :response, presence: true

  # def response=(args)
  #   if args.is_a? Hash
  #     raise ArgumentError unless Date.valid_date?(args[1],args[2],args[3])
  #   end
  #   super(args)
  # rescue ArgumentError
    # super({1=>1, 2=>2, 3=>2020})
  #   @setter_errors ||= {}
  #   @setter_errors[:response] ||= []
  #   @setter_errors[:response] << 'invalid date'
  # end
  #
  # def validate_no_setter_errors
  #   @setter_errors ||= {}
  #   @setter_errors&.each do |attribute, messages|
  #     messages.each do |message|
  #       errors.add(attribute, message)
  #     end
  #   end
  #   @setter_errors.empty?
  # end

end
