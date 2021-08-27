class SupportRequestForm
  STEPS = %w(step1 step2 step3).freeze

  include ActiveModel::Model
  attr_accessor :support_request

  delegate SupportRequest.attribute_names.map { |attr| [attr, "#{attr}="] }.flatten, to: :user

  def initialize(support_request_attributes)
    @support_request = SupportRequest.new(support_request_attributes)
  end

  class Step1 < SupportRequestForm
    #validates :xxx
  end

  class Step2 < Step1
    #validates :xxx
  end

  class Step3 < Step2
    #validates :xxx
  end
end
