module Support
  class Management::SchoolsEmails::SchoolsEmailsTemplates::TemplatesController < ::Support::Management::BaseController
    require "will_paginate/array"
    before_action :initialize_template_groups, only: %i[index create]
    before_action :load_energy_templates, only: %i[index create]
    before_action :set_energy_type_and_option, only: %i[index create]

    def index
      @energy_email_template = find_or_initialize_email_template
    end

    def create
      @energy_email_template = find_or_initialize_email_template
      @energy_email_template.support_email_templates_id = form_params[:template_id]
      @energy_email_template.form_context = "email_template_form"

      if @energy_email_template.save
        redirect_to portal_management_energy_for_schools_path, notice: I18n.t("support.management.energy_for_schools.flash.updated")
      else
        render :index
      end
    end

  private

    def set_energy_type_and_option
      @energy_type = Energy::EmailTemplateConfiguration.energy_types[params[:schools_email_type]&.to_sym]
      @configure_option = Energy::EmailTemplateConfiguration.configure_options[params[:schools_emails_template_type]&.to_sym]
    end

    def find_or_initialize_email_template
      Energy::EmailTemplateConfiguration.find_or_initialize_by(
        energy_type: @energy_type,
        configure_option: @configure_option,
      ).tap do |template|
        template.template_id ||= template.support_email_templates_id if template.persisted?
      end
    end

    def form_params
      params.require(:school_email_template_form).permit(:schools_email_type, :schools_emails_template_type, :template_id)
    end

    def initialize_template_groups
      @system_group = Support::EmailTemplateGroup.find_by(title: "System")
      if @system_group.present?
        @system_subgroup = Support::EmailTemplateGroup.find_by(title: "DfE Energy for Schools", parent_id: @system_group.id)
      end
    end

    def load_energy_templates
      parser = Email::TemplateParser.new
      filters = params.fetch(:email_template_filters, {}).permit(:group_id, subgroup_ids: [])
      filters[:group_id] = @system_group&.id
      filters[:subgroup_ids] = [@system_subgroup&.id]
      @filter_form = Support::Management::EmailTemplateFilterForm.new(**filters.to_h)
      @templates = @filter_form.results.map { |e| Support::EmailTemplatePresenter.new(e, parser) }.paginate(page: params[:page])
    end

    def redirect_path
      is_user_cec_agent? ? cec_management_agents_path : support_management_agents_path
    end

    helper_method def is_user_cec_agent?
      (current_agent.roles & %w[cec cec_admin]).any?
    end

    helper_method def portal_management_energy_for_schools_path
      send("#{portal_namespace}_management_energy_for_schools_path")
    end

    helper_method def portal_management_path
      send("#{portal_namespace}_management_path")
    end

    def authorize_agent_scope = [super, :manage_agents?]
  end
end
