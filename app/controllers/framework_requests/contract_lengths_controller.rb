module FrameworkRequests
  class ContractLengthsController < BaseController
    skip_before_action :authenticate_user!

    before_action :edit_back_url, only: %i[update]

    def update
      if @form.valid?
        @form.save!
        if flow.unfinished?
          redirect_to edit_framework_request_contract_start_date_path(framework_request)
        else
          redirect_to framework_request_path(framework_request), notice: I18n.t("support_request.flash.updated")
        end
      else
        render :edit
      end
    end

  private

    def form
      @form ||= FrameworkRequests::ContractLengthForm.new(all_form_params)
    end

    def form_params
      [:contract_length]
    end

    def create_redirect_path
      contract_start_date_framework_requests_path(framework_support_form: form.common)
    end

    def back_url
      @back_url = categories_framework_requests_path(category_path: framework_request.category&.ancestors_slug, framework_support_form: @form.common)
    end

    def edit_back_url
      @back_url =
        if flow.unfinished?
          edit_framework_request_category_path(framework_support_form: form.common)
        else
          framework_request_path(form.framework_request)
        end
    end
  end
end
