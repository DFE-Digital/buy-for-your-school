module Support
  module Management
    class EmailTemplatesController < BaseController
      require "will_paginate/array"

      def index
        parser = Email::TemplateParser.new
        @filter_form = Support::Management::EmailTemplateFilterForm.new(**filter_params)
        @templates = @filter_form.results.map { |e| Support::EmailTemplatePresenter.new(e, parser) }.paginate(page: params[:page])
      end

      def new
        @form = Support::Management::EmailTemplateForm.new
      end

      def edit
        @form = Support::Management::EmailTemplateForm.from_email_template(params[:id])
        @template_title = @form.email_template.title
      end

      def create
        @form = Support::Management::EmailTemplateForm.new(form_params)
        if @form.valid?
          @form.save!
          redirect_to support_management_email_templates_path, success: I18n.t("support.management.email_templates.create.notice")
        else
          render :new
        end
      end

      def update
        @form = Support::Management::EmailTemplateForm.new(form_params)
        if @form.valid?
          @form.save!
          redirect_to support_management_email_templates_path, success: I18n.t("support.management.email_templates.update.notice")
        else
          render :edit
        end
      end

      def destroy
        Support::EmailTemplate.find(params[:id]).archive!(current_agent)
        redirect_to support_management_email_templates_path, success: I18n.t("support.management.email_templates.destroy.notice")
      end

      def attachment_list
        files = Support::EmailTemplate.find(params[:id]).attachments&.map do |attachment|
          {
            file_id: attachment.id,
            name: attachment.file_name,
            type: Support::Emails::Attachments.get_type(attachment.class),
            url: support_document_download_path(attachment, type: attachment.class),
          }
        end
        render status: :ok, json: files.to_json
      end

    private

      def authorize_agent_scope = [super, :access_proc_ops_portal?]

      def form_params
        params.require(:email_template_form).permit(
          :group_id, :subgroup_id, :stage, :title, :description, :subject, :body, :blob_attachments, file_attachments: []
        ).merge(id: params[:id], agent: current_agent)
      end

      def filter_params
        params.fetch(:email_template_filters, {}).permit(:group_id, :remove_group, :remove_subgroup, :remove_stage, subgroup_ids: [], stages: [])
      end
    end
  end
end
