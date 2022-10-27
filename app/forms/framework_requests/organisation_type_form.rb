module FrameworkRequests
  class OrganisationTypeForm < BaseForm
    validates :school_type, presence: true
  end
end
