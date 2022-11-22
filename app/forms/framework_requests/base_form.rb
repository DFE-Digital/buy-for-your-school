module FrameworkRequests
  class BaseForm
    include ActiveModel::Model

    delegate :allow_bill_upload?, to: :framework_request

    attr_accessor(
      :id,
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

      to_h.slice(:dsi, :school_type, :org_confirm, :special_requirements_choice)
    end

    def framework_request
      FrameworkRequest.find(@id)
    end
  end
end
