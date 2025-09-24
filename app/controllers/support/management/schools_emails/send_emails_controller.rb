module Support
  class Management::SchoolsEmails::SendEmailsController < ::Support::Management::BaseController
    before_action :set_energy_type_and_option, only: %i[index create]
    def index
      @energy_email_template = find_or_initialize_email_template
      @energy_email_template.to_email_ids = @energy_email_template.to_email_ids&.join("; ") || ""
    end

    def create
      @energy_email_template = find_or_initialize_email_template
      @energy_email_template.to_email_ids = parse_email_ids(form_params[:to_email_ids])
      @energy_email_template.form_context = "supplier_email_form"

      if @energy_email_template.save
        redirect_to portal_management_energy_for_schools_path, notice: I18n.t("support.management.energy_for_schools.flash.updated")
      else
        @energy_email_template.to_email_ids = form_params[:to_email_ids]
        render :index
      end
    end

  private

    def set_energy_type_and_option
      @energy_type = Energy::EmailTemplateConfiguration.energy_types[params[:schools_email_type]&.to_sym]
      @configure_option = params[:schools_email_type] == "electricity" ? 0 : 5
    end

    def find_or_initialize_email_template
      Energy::EmailTemplateConfiguration.find_or_initialize_by(
        energy_type: @energy_type,
        configure_option: @configure_option,
      )
    end

    def parse_email_ids(email_ids)
      email_ids&.split(";")&.map(&:strip) || []
    end

    def form_params
      params.require(:school_emails).permit(:schools_email_type, :to_email_ids)
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
