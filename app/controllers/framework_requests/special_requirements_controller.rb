module FrameworkRequests
  class SpecialRequirementsController < BaseController
    skip_before_action :authenticate_user!

    def create
      if @form.valid?
        session.delete(:support_journey) unless current_user.guest?
        session.delete(:framework_request_id)
        redirect_to framework_request_path(@form.framework_request)
      else
        render :index
      end
    end

  private

    def form
      @form ||= FrameworkRequests::SpecialRequirementsForm.new(all_form_params)
    end

    def form_params
      [:special_requirements]
    end

    def back_url
      @back_url = procurement_confidence_framework_requests_path(framework_support_form: form.common)
    end

    def step_description
      I18n.t("request.special_requirements.heading")
    end
  end
end
