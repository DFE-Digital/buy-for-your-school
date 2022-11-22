module FrameworkRequests
  class SearchForOrganisationForm < BaseForm
    validate :organisation_id_validation

    attr_accessor :organisation_id, :organisation_type

    attr_reader :organisation_name

    def initialize(attributes = {})
      super
      @school_type ||= framework_request.group? ? "group" : "school"
      @organisation_id ||= framework_request.organisation_id unless changing_school_types?
      @organisation_type ||= framework_request.organisation_type unless changing_school_types?
      @organisation_name = organisation&.formatted_name if @organisation_id.present?
    end

    def save!
      # no op
    end

    def organisation_id_validation
      errors.add(:organisation_id, I18n.t("framework_request.errors.rules.organisation_id.#{@school_type}")) if @organisation_id.blank? || organisation.nil?
    end

    def find_other_type
      to_h
        .except(:id, :errors, :organisation_id, :organisation_type, :organisation_name, :org_confirm, :user)
        .merge(school_type: flipped_school_type, organisation_id: nil)
    end

    def flipped_school_type
      @school_type == "group" ? "school" : "group"
    end

    def changing_school_types?
      @school_type && group? && !framework_request.group ||
        @school_type && !group? && framework_request.group
    end

  private

    def organisation
      @organisation_type&.safe_constantize&.find_by(id: @organisation_id)
    end
  end
end
