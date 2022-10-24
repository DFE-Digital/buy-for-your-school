module FrameworkRequests
  class BaseController < ApplicationController
    before_action :form, only: %i[index create update edit]
    before_action :back_url, except: %i[edit]
    # before_action :cached_orgs
    before_action :create_user_journey_step, only: %i[index]

    def index; end

    def create
      if @form.valid?
        @form.save!
        redirect_to create_redirect_path
      else
        render :index
      end
    end

    def edit
      # @form =
      #   FrameworkSupportForm.new(
      #     id: framework_request_id,
      #     user: current_user,
      #     dsi: !current_user.guest?,
      #     **persisted_data,
      #     **cached_search_result,
      #   )
      # @form = FrameworkSupportForm.from_framework_request(framework_request_id: params[:id], user: current_user)
      # @form = FrameworkRequests::BaseForm.new(all_form_params)
      @back_url = edit_back_url
    end

    def update
      if @form.valid?
        @form.save!
        redirect_to framework_request_path(framework_request), notice: I18n.t("support_request.flash.updated")
      else
        render :edit
      end
    end

  private

    def form
      @form ||= FrameworkRequests::BaseForm.new(all_form_params)
    end

    def all_form_params
      params.fetch(:framework_support_form, {}).permit(*%i[
        dsi
        group
        org_confirm
      ], *form_params).merge(id: framework_request_id, user: current_user)
    end

    def validation
      @validation ||= FrameworkSupportFormSchema.new.call(**all_form_params)
    end

    # @return [FrameworkRequestPresenter]
    def framework_request
      @framework_request ||= FrameworkRequestPresenter.new(FrameworkRequest.find(framework_request_id))
    end

    def framework_request_id
      return session[:framework_request_id] if session[:framework_request_id]
      return params[:id] if params[:id]

      session[:framework_request_id] = FrameworkRequest.create!.id
      session[:framework_request_id]
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

    # def cached_orgs
    #   @cached_group = session[:faf_group]
    #   @cached_school = session[:faf_school]
    # end

    def back_url; end

    def edit_back_url
      framework_request_path(form.framework_request)
    end

    def create_redirect_path; end

    def update_redirect_path; end

    def update_data; end

    def step_description; end

    def form_params; end
  end
end
