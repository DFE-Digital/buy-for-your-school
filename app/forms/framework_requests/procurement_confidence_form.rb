module FrameworkRequests
  class ProcurementConfidenceForm < BaseForm
    validates :confidence_level, presence: true

    attr_accessor :confidence_level

    def initialize(attributes = {})
      super
      @confidence_level ||= framework_request.confidence_level
    end

    def confidence_levels
      Request.confidence_levels.keys.reverse
    end
  end
end
