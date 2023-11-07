module FrameworkRequests
  class OriginsController < BaseController
    skip_before_action :authenticate_user!

    def create
      if @form.valid?
        @form.save!
        session.delete(:support_journey) unless current_user.guest?
        redirect_to framework_request_path(@form.framework_request)
      else
        render :index
      end
    end

  private

    def form
      @form ||= FrameworkRequests::OriginForm.new(all_form_params)
    end

    def form_params
      %i[origin origin_other]
    end

    def back_url
      @back_url = special_requirements_framework_requests_path(framework_support_form: @form.common)
    end
  end
end
