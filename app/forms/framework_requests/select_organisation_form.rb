module FrameworkRequests
  class SelectOrganisationForm < BaseForm
    validates :organisation_id, presence: true

    attr_accessor :organisation_id, :group

    def initialize(attributes = {})
      super
      @organisation_id ||= framework_request.organisation&.gias_id
      @group ||= framework_request.group
    end

    def data
      super.merge(organisation:).except(:organisation_id)
    end

  private

    def organisation_type
      ActiveModel::Type::Boolean.new.cast(@group) ? Support::EstablishmentGroup : Support::Organisation
    end

    def organisation
      organisation_type.find_by_gias_id(@organisation_id)
    end
  end
end
