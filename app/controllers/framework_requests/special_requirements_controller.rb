module FrameworkRequests
  class SpecialRequirementsController < BaseController
    skip_before_action :authenticate_user!

    def create
      if validation.success?
        session.delete(:support_journey) unless current_user.guest?
        request = FrameworkRequest.create!(@form.data)
        redirect_to framework_request_path(request)
      else
        render :index
      end
    end

  private

    def update_data
      { special_requirements: @form.special_requirements }
    end

    def back_url
      @back_url = procurement_confidence_framework_requests_path(framework_support_form: validation.to_h)
    end
  end
end
