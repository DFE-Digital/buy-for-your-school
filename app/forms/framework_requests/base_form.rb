module FrameworkRequests
  class BaseForm
    include ActiveModel::Model

    attr_accessor(
      :id,
      :dsi,
      :group,
      :user,
      :org_confirm,
      :special_requirements_choice,
    )

    def save!
      framework_request.update!(data)
    end

    def dsi?
      ActiveModel::Type::Boolean.new.cast(@dsi)
    end

    def group?
      ActiveModel::Type::Boolean.new.cast(@group)
    end

    def org_confirm?
      ActiveModel::Type::Boolean.new.cast(@org_confirm)
    end

    def to_h
      instance_values.symbolize_keys
    end

    def data
      to_h.except(:id, :dsi, :org_confirm, :special_requirements_choice, :user, :validation_context, :errors)
    end

    def common
      to_h.slice(:dsi, :group, :org_confirm, :special_requirements_choice)
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
