module FrameworkRequests
  class ConfirmOrganisationForm < BaseForm
    validate :org_confirm_validation

    attr_accessor :org_id

    def initialize(attributes = {})
      super
      @org_id = found_uid_or_urn || framework_request.org_id
    end

    def save!
      super if org_confirm?
    end

    def data
      super.merge(group: group?)
    end

    def org_confirm_validation
      return if org_confirm.present?

      org_type = @school_type
      errors.add(:org_confirm, I18n.t("framework_request.errors.rules.org_confirm.#{org_type}"))
    end

    def school_or_group
      if group?
        group = Support::EstablishmentGroup.find_by(uid: @org_id)
        Support::EstablishmentGroupPresenter.new(group)
      else
        school = Support::Organisation.find_by(urn: @org_id)
        Support::OrganisationPresenter.new(school)
      end
    end
  end
end
