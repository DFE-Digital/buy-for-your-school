module FrameworkRequests
  class ConfirmSignInController < BaseController
    def index
      @current_user = UserPresenter.new(current_user)
    end

    def create
      set_inferred_attrbutes
      redirect_to create_redirect_path
    end

  private

    def create_redirect_path
      @current_user = UserPresenter.new(current_user)
      if @current_user.single_org?
        message_framework_requests_path(framework_support_form: form.data)
      else
        select_organisation_framework_requests_path
      end
    end

    def set_inferred_attrbutes
      framework_request.attributes = {
        user: current_user,
        first_name: current_user.first_name,
        last_name: current_user.last_name,
        email: current_user.email,
      }

      @current_user = UserPresenter.new(current_user)
      assign_org if @current_user.single_org?

      framework_request.save!
    end

    def assign_org
      if @current_user.school_urn
        framework_request.attributes = { org_id: @current_user.school_urn, group: false }
      elsif @current_user.group_uid
        framework_request.attributes = { org_id: @current_user.group_uid, group: true }
      end
    end
  end
end
