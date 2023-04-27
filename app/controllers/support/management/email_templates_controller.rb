module Support
  module Management
    class EmailTemplatesController < BaseController
      require "will_paginate/array"

      def index
        parser = Support::Emails::Templates::Parser.new(agent: current_agent)
        @templates = Support::EmailTemplate.active.map { |e| Support::EmailTemplatePresenter.new(e, parser) }.paginate(page: params[:page])
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

    private

      def form_params
        params.require(:email_template_form).permit(*%i[
          group_id subgroup_id stage title description subject body
        ]).merge(id: params[:id], agent: current_agent)
      end
    end
  end
end
