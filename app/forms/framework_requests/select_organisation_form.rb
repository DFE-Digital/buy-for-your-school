module FrameworkRequests
  class SelectOrganisationForm < BaseForm
    validates :org_id, presence: true

    attr_accessor :org_id, :group

    def initialize(attributes = {})
      super
      @org_id ||= framework_request.org_id
      @group ||= framework_request.group
    end
  end
end
