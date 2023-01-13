module Support
  class InteractionsController < ApplicationController
    before_action :safe_interaction, only: :new

    def index; end

    def show
      @interaction = InteractionPresenter.new(current_case.interactions.find(params[:id]))
    end

    def new
      @interaction = InteractionPresenter.new(current_case.interactions.build)
      @back_url = support_case_path(current_case)
      render :new, locals: { option: safe_interaction }
    end

    def create
      @interaction = InteractionPresenter.new(Interaction.new(interaction_params))
      if @interaction.save
        record_action(case_id: @interaction.case.id, action: "add_interaction", data: { event_type: @interaction.event_type })

        redirect_to determine_redirect_path(@interaction.event_type),
                    notice: I18n.t("support.interaction.message.created_flash", type: @interaction.event_type).humanize
      else
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

    def determine_redirect_path(event_type)
      case event_type
      when "note"
        support_case_path(current_case, anchor: "case-history")
      else
        logged_contacts_support_case_message_threads_path(current_case)
      end
    end
  end
end
