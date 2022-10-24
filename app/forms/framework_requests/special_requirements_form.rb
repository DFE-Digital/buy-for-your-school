module FrameworkRequests
  class SpecialRequirementsForm < BaseForm
    validates :special_requirements, presence: true

    attr_accessor :special_requirements

    def initialize(attributes = {})
      super
      @special_requirements ||= framework_request.special_requirements
    end
  end
end
