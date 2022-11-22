module FrameworkRequests
  class SearchForOrganisationsController < BaseController
    skip_before_action :authenticate_user!

    before_action :edit_route?

    def create
      if @form.valid?
        redirect_to create_redirect_path
      else
        render :index
      end
    end

    def update
      if @form.valid?
        redirect_to update_redirect_path
      else
        render :edit
      end
    end

    def edit_route?
      @edit_route = request.path.end_with?("/edit")
    end

  private

    def form
      all_params = all_form_params
      # override the "group" in framework_support_form if "group" on its own is provided
      all_params[:school_type] = params[:school_type] if params[:school_type]
      @form ||= FrameworkRequests::SearchForOrganisationForm.new(all_params)
    end

    def form_params
      %i[organisation_id organisation_type]
    end

    def create_redirect_path
      confirm_organisation_framework_requests_path(framework_support_form: @form.common.merge(organisation_id: all_form_params[:organisation_id], organisation_type: all_form_params[:organisation_type]))
    end

    def update_redirect_path
      edit_framework_request_confirm_organisation_path(framework_support_form: @form.common.merge(organisation_id: all_form_params[:organisation_id], organisation_type: all_form_params[:organisation_type]))
    end

    def back_url
      @back_url = organisation_type_framework_requests_path(framework_support_form: @form.common)
    end
  end
end
