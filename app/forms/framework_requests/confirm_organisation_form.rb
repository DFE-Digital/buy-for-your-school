module FrameworkRequests
  class ConfirmOrganisationForm < BaseForm
    validates :org_confirm, presence: true

    def save!
      # no op
    end

    def school_or_group
      if group?
        group = Support::EstablishmentGroup.find_by(uid: framework_request.org_id)
        Support::EstablishmentGroupPresenter.new(group)
      else
        school = Support::Organisation.find_by(urn: framework_request.org_id)
        Support::OrganisationPresenter.new(school)
      end
    end
  end
end
