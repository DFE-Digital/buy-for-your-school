module FrameworkRequests
  class SameSupplierForm < BaseForm
    validates :same_supplier_used, presence: true

    attr_accessor :same_supplier_used

    def initialize(attributes = {})
      super
      @same_supplier_used ||= framework_request.same_supplier_used
    end
  end
end
