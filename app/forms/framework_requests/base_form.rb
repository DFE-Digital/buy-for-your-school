module FrameworkRequests
  class BaseForm
    include ActiveModel::Model

    attr_accessor(
      :id,
      :is_energy_request,
      :energy_request_about,
      :have_energy_bill,
      :energy_alternative,
      :dsi,
      :school_type,
      :user,
      :org_confirm,
      :special_requirements_choice,
    )

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
      @school_type == "group"
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
        :is_energy_request,
        :energy_request_about,
        :have_energy_bill,
        :energy_alternative,
        :dsi,
        :school_type,
        :org_confirm,
        :special_requirements_choice,
        :user,
        :validation_context,
        :errors,
      )
    end

    def common
      return {} unless @user.guest?

      to_h.slice(:dsi, :is_energy_request, :energy_request_about, :have_energy_bill, :energy_alternative, :school_type, :org_confirm, :special_requirements_choice)
    end

    def framework_request
      FrameworkRequest.find(@id)
    end

  private

    def found_uid_or_urn
      @org_id&.split(" - ")&.first
    end
  end
end
