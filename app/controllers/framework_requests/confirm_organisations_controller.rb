module FrameworkRequests
  class ConfirmOrganisationsController < BaseController
    skip_before_action :authenticate_user!

    before_action :form, only: %i[index edit create update]

    def index; end

    def create
      if validation.success?
        cache_search_result!
        @form.forward
        redirect_to create_redirect_path
      else
        render :index
      end
    end

    def edit
      @back_url = edit_back_url
    end

    def update
      if validation.success?
        if @form.org_confirm
          cache_search_result!
          framework_request.update!(group: @form.group, org_id: @form.found_uid_or_urn)
          redirect_to framework_request_path(framework_request), notice: I18n.t("support_request.flash.updated")
        else
          redirect_to edit_framework_request_search_for_organisation_path(framework_request, group: @form.group)
        end
      else
        render :edit
      end
    end

  private

    def create_redirect_path
      if @form.org_confirm
        name_framework_requests_path(framework_support_form: validation.to_h)
      else
        back_url
      end
    end

    def cache_search_result!
      if @form.group
        session[:faf_group] = @form.org_id
        session.delete(:faf_school)
      else
        session[:faf_school] = @form.org_id
        session.delete(:faf_group)
      end
    end

    def back_url
      @back_url = search_for_organisation_framework_requests_path(framework_support_form: validation.to_h)
    end

    def edit_back_url
      @back_url = edit_framework_request_search_for_organisation_path(framework_support_form: validation.to_h)
    end
  end
end
