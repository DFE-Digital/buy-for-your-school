module FrameworkRequest::AttributesInferrable
  extend ActiveSupport::Concern

  class_methods do
    def create_with_inferred_attributes!(user_presenter)
      return create if user_presenter.guest?

      framework_request = new
      framework_request.set_inferred_attributes!(user_presenter)
      framework_request
    end
  end

  def set_inferred_attributes!(user_presenter)
    return if user_presenter.guest?

    self.attributes = {
      user: user_presenter.to_model,
      first_name: user_presenter.first_name,
      last_name: user_presenter.last_name,
      email: user_presenter.email,
    }

    assign_org(user_presenter) if user_presenter.single_org?

    save!
  end

private

  def assign_org(user_presenter)
    if user_presenter.school_urn
      self.attributes = { org_id: user_presenter.school_urn, group: false }
    elsif user_presenter.group_uid
      self.attributes = { org_id: user_presenter.group_uid, group: true }
    end
  end
end
