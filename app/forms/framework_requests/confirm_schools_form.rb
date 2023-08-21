module FrameworkRequests
  class ConfirmSchoolsForm < BaseForm
    attr_accessor :school_urns, :school_urns_confirmed

    validates :school_urns_confirmed, presence: true

    def initialize(attributes = {})
      super
      @school_urns ||= framework_request.school_urns
      @school_urns_confirmed ||= (framework_request.school_urns.present? && @school_urns == framework_request.school_urns) || nil
    end

    def selected_schools
      @school_urns.map { |urn| Support::OrganisationPresenter.new(Support::Organisation.find_by(urn:)) }
    end

    def school_urns_confirmed?
      ActiveModel::Type::Boolean.new.cast(@school_urns_confirmed)
    end

    def save!
      super if school_urns_confirmed
    end

    def common_with_school_urns
      common.merge(school_urns:)
    end

    def data
      super.except(:school_urns_confirmed)
    end
  end
end
