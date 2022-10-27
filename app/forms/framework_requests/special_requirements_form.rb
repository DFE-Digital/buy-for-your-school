module FrameworkRequests
  class SpecialRequirementsForm < BaseForm
    validates :special_requirements_choice, presence: true
    validates :special_requirements, presence: true, if: :special_requirements_choice?

    attr_accessor :special_requirements_choice, :special_requirements

    def initialize(attributes = {})
      super
      @special_requirements ||= framework_request.special_requirements
    end

    def save!
      @special_requirements = nil unless special_requirements_choice?
      super
    end

    def special_requirements_choice?
      @special_requirements_choice == "yes"
    end
  end
end
