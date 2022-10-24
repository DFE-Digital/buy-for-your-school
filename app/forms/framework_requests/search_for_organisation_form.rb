module FrameworkRequests
  class SearchForOrganisationForm < BaseForm
    validates :org_id, presence: true

    attr_accessor :org_id

    def initialize(attributes = {})
      super
      @org_id ||= formatted_org_name
    end

    def data
      super.merge(org_id: found_uid_or_urn)
    end

    def find_other_type
      to_h
        .except(:id, :errors, :org_id, :org_confirm, :user)
        .merge(group: !group?, org_id: nil)
    end

    def formatted_org_name
      # byebug
      return unless framework_request.org_id

      framework_request = FrameworkRequestPresenter.new(framework_request)
      "#{framework_request.org_id} - #{framework_request.org_name}"
    end
  end
end
