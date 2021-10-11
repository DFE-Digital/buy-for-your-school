module Support
  class InteractionsController < ApplicationController
    before_action :safe_interaction, only: :new

    def index; end

    def show; end

    def new
      @interaction = current_case.interactions.build
      @back_url = support_case_path(current_case)
      render :new, locals: { option: safe_interaction }
    end

    def create
      @interaction = Interaction.new(interaction_params)
      if @interaction.save
        redirect_to support_case_path(@interaction.case),
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
  end
end
