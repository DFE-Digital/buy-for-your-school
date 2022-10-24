module FrameworkRequests
  class OrganisationTypeForm < BaseForm
    validates :group, presence: true
  end
end
