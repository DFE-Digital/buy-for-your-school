module FrameworkRequests
  class SpecialRequirementsController < BaseController
    skip_before_action :authenticate_user!

    def create
      if @form.valid?
        @form.save!
        session.delete(:support_journey) unless current_user.guest?
        session.delete(:framework_request_id)
        redirect_to framework_request_path(@form.framework_request)
      else
        render :index
      end
    end

    def edit
      super
      @form.special_requirements_choice = framework_request.special_requirements == "-" ? "no" : "yes"
    end

  private

    def form
      @form ||= FrameworkRequests::SpecialRequirementsForm.new(all_form_params)
    end

    def form_params
      [:special_requirements]
    end

    def back_url
      @back_url = determine_back_path
    end

    def determine_back_path
      return categories_framework_requests_path(category_path: framework_request.category&.ancestors_slug, framework_support_form: @form.common) if form.allow_bill_upload?

      procurement_amount_framework_requests_path(framework_support_form: form.common)
    end
  end
end
