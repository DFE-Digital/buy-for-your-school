module FrameworkRequests
  class SearchForOrganisationForm < BaseForm
    validate :org_id_validation

    attr_accessor :org_id

    def initialize(attributes = {})
      super
      # don't set the organisation if we're in the middle of changing org types
      @org_id ||= formatted_org_name unless changing_school_types?
      @school_type ||= framework_request.group? ? "group" : "school"
    end

    def save!
      # no op
    end

    def changing_school_types?
      @school_type && group? && !framework_request.group ||
        @school_type && !group? && framework_request.group
    end

    def org_id_validation
      return if org_id.present?

      org_type = @school_type
      errors.add(:org_id, I18n.t("framework_request.errors.rules.org_id.#{org_type}"))
    end

    def find_other_type
      to_h
        .except(:id, :errors, :org_id, :org_confirm, :user)
        .merge(school_type: flipped_school_type, org_id: nil)
    end

    def flipped_school_type
      @school_type == "group" ? "school" : "group"
    end

    def formatted_org_name
      return unless framework_request.org_id

      presenter = FrameworkRequestPresenter.new(framework_request)
      "#{presenter.org_id} - #{presenter.org_name}"
    end
  end
end
