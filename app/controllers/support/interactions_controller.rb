module Support
  class InteractionsController < ApplicationController
    before_action :safe_interaction, only: :new
    helper_method :back_to_param

    def index; end

    def show
      @interaction = InteractionPresenter.new(current_case.interactions.find(params[:id]))
    end

    def new
      @interaction = InteractionPresenter.new(current_case.interactions.build)
      @back_url = set_back_url
      render :new, locals: { option: safe_interaction }
    end

    def create
      @interaction = InteractionPresenter.new(Interaction.new(interaction_params))

      if @interaction.valid?
        create_interaction

        redirect_to determine_redirect_path(@interaction.event_type),
                    notice: I18n.t("support.interaction.message.created_flash", type: @interaction.event_type).humanize
      else
        @back_url = set_back_url

        render :new, locals: { option: safe_interaction }
      end
    end

  private

    def interaction_params
      params.require(:interaction).permit(:event_type, :body).merge(agent_id: current_agent.id, case: current_case)
    end

    def safe_interaction
      @option = Support::Interaction::SAFE_INTERACTIONS.find { |opt| opt == params[:option].to_s } ||
        redirect_to(support_case_path(current_case))
    end

    def current_case
      @current_case || Case.find(params[:case_id])
    end

    def back_to_param
      params[:back_to] || params.dig(:interaction, :back_to)
    end

    def determine_redirect_path(event_type)
      back_to = back_link_param(back_to_param)
      return back_to if back_to.present?

      case event_type
      when "note"
        is_user_cec_agent? ? cec_onboarding_case_path(current_case, anchor: "case-history") : support_case_path(current_case, anchor: "case-history")
      else
        logged_contacts_support_case_message_threads_path(current_case)
      end
    end

    def create_interaction
      CaseManagement::CreateInteraction.new.call(
        support_case_id: @interaction.case.id,
        agent_id: @interaction.agent.id,
        event_type: @interaction.event_type,
        body: @interaction.body,
      )
    end

    def set_back_url
      back_link_param || (is_user_cec_agent? ? cec_onboarding_case_path(current_case) : support_case_path(current_case))
    end

    helper_method def portal_case_interactions_path
      send("#{agent_portal_namespace}_case_interactions_path")
    end

    helper_method def portal_case_logged_contacts_path(current_case)
      if is_user_cec_agent?
        send("cec_case_logged_contacts_path", current_case)
      else
        send("logged_contacts_support_case_message_threads_path", current_case)
      end
    end

    def authorize_agent_scope = :access_individual_cases?
  end
end
