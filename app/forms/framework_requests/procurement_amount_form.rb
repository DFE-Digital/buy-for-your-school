module FrameworkRequests
  class ProcurementAmountForm < BaseForm
    validates :procurement_amount, presence: true

    attr_accessor :procurement_amount

    def initialize(attributes = {})
      super
      @procurement_amount ||= framework_request.procurement_amount
    end
  end
end
