module FrameworkRequests
  class BaseController < ApplicationController
    before_action :form, only: %i[index create update]
    before_action :framework_request, only: %i[edit update]
    before_action :back_url, except: %i[edit]
    before_action :cached_orgs

    def index; end

    def create
      if validation.success?
        @form.forward
        redirect_to create_redirect_path
      else
        render :index
      end
    end

    def edit
      @form =
        FrameworkSupportForm.new(
          user: current_user,
          dsi: !current_user.guest?,
          **persisted_data,
          **cached_search_result,
        )
      @back_url = edit_back_url
    end

    def update
      if validation.success?
        framework_request.update!(update_data)
        redirect_to framework_request_path(framework_request), notice: I18n.t("support_request.flash.updated")
      else
        render :edit
      end
    end

  private

    def form
      return unless params.key?(:framework_support_form)

      @form =
        FrameworkSupportForm.new(
          user: current_user,
          messages: validation.errors(full: true).to_h,
          **validation.to_h,
        )
    end

    def form_params
      params.require(:framework_support_form).permit(*%i[
        step
        back
        dsi
        group
        org_id
        org_confirm
        first_name
        last_name
        email
        message_body
        procurement_amount
        confidence_level
        special_requirements_choice
        special_requirements
      ])
    end

    def validation
      @validation ||= FrameworkSupportFormSchema.new.call(**form_params)
    end

    # @return [FrameworkRequestPresenter]
    def framework_request
      @framework_request = FrameworkRequestPresenter.new(FrameworkRequest.find(params[:id]))
    end

    # @return [Hash]
    def persisted_data
      framework_request.attributes.symbolize_keys
    end

    def cached_search_result
      return {} unless current_user.guest?

      case params[:group]
      when "true"
        { group: params[:group], org_id: session[:faf_group] }
      when "false"
        { group: params[:group], org_id: session[:faf_school] }
      else
        {}
      end
    end

    def cached_orgs
      @cached_group = session[:faf_group]
      @cached_school = session[:faf_school]
    end

    def back_url; end

    def edit_back_url
      framework_request_path(framework_request)
    end

    def create_redirect_path; end

    def update_redirect_path; end

    def update_data; end
  end
end
