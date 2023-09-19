module FrameworkRequests
  class BaseForm
    include ActiveModel::Model

    attr_accessor(
      :id,
      :dsi,
      :school_type,
      :user,
      :org_confirm,
      :special_requirements_choice,
    )

    attr_writer :source

    def initialize(attributes = {})
      super
      @user = UserPresenter.new(@user)
    end

    def save!
      framework_request.update!(data)
    end

    def dsi?
      ActiveModel::Type::Boolean.new.cast(@dsi)
    end

    def group?
      @school_type.present? ? @school_type == "group" : framework_request.group
    end

    def org_confirm?
      ActiveModel::Type::Boolean.new.cast(@org_confirm)
    end

    def to_h
      instance_values.symbolize_keys
    end

    def data
      to_h.except(
        :id,
        :dsi,
        :school_type,
        :org_confirm,
        :special_requirements_choice,
        :source,
        :user,
        :validation_context,
        :errors,
      )
    end

    def common
      return to_h.slice(:source) unless @user.guest?

      to_h.slice(:dsi, :school_type, :org_confirm, :special_requirements_choice, :source)
    end

    def framework_request
      FrameworkRequest.find(@id)
    end

    def school_or_group
      framework_request.organisation
    end

    def eligible_for_school_picker? = group? && (school_or_group.federation? || school_or_group.mat_or_trust?) && school_or_group.organisations.present?

    def source
      (@source || "").inquiry
    end

  private

    def found_uid_or_urn
      @org_id&.split(" - ")&.first
    end
  end
end
