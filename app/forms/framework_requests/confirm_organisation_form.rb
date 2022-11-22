module FrameworkRequests
  class ConfirmOrganisationForm < BaseForm
    validate :org_confirm_validation

    attr_accessor :organisation_id, :organisation_type

    def initialize(attributes = {})
      super
      @organisation_id ||= framework_request.organisation_id
      @organisation_type ||= framework_request.organisation_type
    end

    def save!
      super if org_confirm?
    end

    def data
      super.merge(organisation:, group: group?).except(:organisation_id, :organisation_type)
    end

    def common
      super.merge(organisation_id: @organisation_id, organisation_type: @organisation_type)
    end

    def org_confirm_validation
      return if org_confirm.present?

      org_type = @school_type
      errors.add(:org_confirm, I18n.t("framework_request.errors.rules.org_confirm.#{org_type}"))
    end

    def school_or_group
      presenter_type.new(organisation)
    end

  private

    def presenter_type
      "#{@organisation_type}Presenter".safe_constantize
    end

    def organisation
      @organisation_type.safe_constantize.find(@organisation_id)
    end
  end
end
