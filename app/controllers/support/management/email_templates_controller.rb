module Support
  module Management
    class EmailTemplatesController < BaseController
      before_action :cec_template_group
      require "will_paginate/array"

      def index
        parser = Email::TemplateParser.new
        @filter_form = Support::Management::EmailTemplateFilterForm.new(**filter_params.to_h)
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
          redirect_to portal_management_email_templates_index_path, success: I18n.t("support.management.email_templates.create.notice")
        else
          render :new
        end
      end

      def update
        @form = Support::Management::EmailTemplateForm.new(form_params)
        if @form.valid?
          @form.save!
          redirect_to portal_management_email_templates_index_path, success: I18n.t("support.management.email_templates.update.notice")
        else
          render :edit
        end
      end

      def destroy
        Support::EmailTemplate.find(params[:id]).archive!(current_agent)
        redirect_to portal_management_email_templates_index_path, success: I18n.t("support.management.email_templates.destroy.notice")
      end

      def attachment_list
        files = Support::EmailTemplate.find(params[:id]).attachments&.map do |attachment|
          {
            file_id: attachment.id,
            name: attachment.file_name,
            type: attachment.class,
            url: support_document_download_path(attachment, type: attachment.class),
          }
        end
        render status: :ok, json: files.to_json
      end

    private

      def authorize_agent_scope = [super, :access_individual_cases?]

      def form_params
        params.require(:email_template_form).permit(
          :group_id, :subgroup_id, :stage, :title, :description, :subject, :body, :blob_attachments, file_attachments: []
        ).merge(id: params[:id], agent: current_agent)
      end

      def filter_params
        filters = params.fetch(:email_template_filters, {}).permit(:group_id, :remove_group, :remove_subgroup, :remove_stage, subgroup_ids: [], stages: [])

        if (current_agent&.roles & %w[cec cec_admin]).any? && params[:email_template_filters].blank?
          filters[:group_id] = @cec_group&.id
          filters[:subgroup_ids] = [@dfe_subgroup&.id]
        end

        filters
      end

      def cec_template_group
        @cec_group = Support::EmailTemplateGroup.find_by(title: "CEC")
        if @cec_group.present?
          @dfe_subgroup = Support::EmailTemplateGroup.find_by(title: "DfE Energy for Schools service", parent_id: @cec_group.id)
        end
      end

      helper_method def portal_management_path
        send("#{agent_portal_namespace}_management_path")
      end

      helper_method def portal_management_email_templates_index_path
        if is_user_cec_agent?
          send("cec_management_email_templates_index_path")
        else
          send("support_management_email_templates_path")
        end
      end

      helper_method def portal_new_management_email_template_path
        if is_user_cec_agent?
          send("cec_new_management_email_template_path")
        else
          send("new_support_management_email_template_path")
        end
      end

      helper_method def portal_management_email_templates_path
        send("#{agent_portal_namespace}_management_email_templates_path")
      end

      helper_method def portal_update_management_email_template_path
        if is_user_cec_agent?
          send("cec_update_management_email_template_path")
        else
          send("support_management_email_template_path")
        end
      end

      helper_method def portal_edit_management_email_template_path(template)
        if is_user_cec_agent?
          send("cec_edit_management_email_template_path", template)
        else
          send("edit_support_management_email_template_path", template)
        end
      end

      helper_method def portal_delete_management_email_template_path(template)
        if is_user_cec_agent?
          send("cec_delete_management_email_template_path", template)
        else
          send("support_management_email_template_path", template)
        end
      end

      helper_method def portal_subgroups_management_email_template_groups_path
        if is_user_cec_agent?
          send("cec_subgroups_management_email_template_groups_path")
        else
          send("subgroups_support_management_email_template_groups_path")
        end
      end
    end
  end
end
