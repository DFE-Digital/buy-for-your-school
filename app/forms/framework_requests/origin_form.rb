module FrameworkRequests
  class OriginForm < BaseForm
    validates :origin, presence: true
    validates :origin_other, presence: true, if: -> { @origin == "other" }

    attr_accessor :origin, :origin_other

    def initialize(attributes = {})
      super
      @origin ||= framework_request.origin
      @origin_other ||= framework_request.origin_other
    end

    def save!
      @origin_other = nil unless @origin == "other"
      super
    end
  end
end
