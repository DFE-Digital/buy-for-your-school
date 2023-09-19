module FrameworkRequests
  class DocumentsController < BaseController
    skip_before_action :authenticate_user!

    before_action :edit_back_url, only: %i[update]

    def update
      if @form.valid?
        @form.save!
        if framework_request.reload.document_types.include?("none")
          redirect_to framework_request_path(framework_request), notice: I18n.t("support_request.flash.updated")
        else
          redirect_to edit_framework_request_document_uploads_path(framework_request)
        end
      else
        render :edit
      end
    end

  private

    def form
      @form ||= FrameworkRequests::DocumentsForm.new(all_form_params)
    end

    def form_params
      [:document_type_other, { document_types: [] }]
    end

    def create_redirect_path
      return special_requirements_framework_requests_path(framework_support_form: @form.common) if framework_request.document_types.include?("none")

      document_uploads_framework_requests_path(framework_support_form: @form.common)
    end

    def back_url
      @back_url = message_framework_requests_path(framework_support_form: @form.common)
    end

    def edit_back_url
      @back_url =
        if framework_request.multischool_with_multiple_selections?
          edit_framework_request_same_supplier_path(framework_request)
        else
          edit_framework_request_contract_start_date_path(framework_request)
        end
    end
  end
end
