module FrameworkRequests
  class SchoolPickerForm < BaseForm
    validates :school_urns, presence: true

    attr_accessor :school_urns, :filters

    def initialize(attributes = {})
      super
      @filters = framework_request.available_schools.filtering(filters || { statuses: %w[opened opening closing] })
      @school_urns ||= framework_request.school_urns
      @school_urns.compact_blank!
    end

    def save!
      # no op
    end

    def common
      super.merge(school_urns: @school_urns.excluding("all"))
    end
  end
end
