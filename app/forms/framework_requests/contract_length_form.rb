module FrameworkRequests
  class ContractLengthForm < BaseForm
    validates :contract_length, presence: true

    attr_accessor :contract_length

    def initialize(attributes = {})
      super
      @contract_length ||= framework_request.contract_length
    end
  end
end
