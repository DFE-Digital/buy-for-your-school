module Support
  class Cases::EvaluatorsController < Cases::ApplicationController
    before_action :set_current_case
    before_action :set_evaluator, only: %i[edit update destroy]

    before_action only: %i[new create edit update destroy] do
      @back_url = support_case_evaluators_path(@current_case)
    end

    before_action only: [:index] do
      @back_url = support_case_path(@current_case, anchor: "tasklist")
    end
    def index
      @evaluators = @current_case.evaluators.all
    end

    def new
      @evaluator = @current_case.evaluators.new
    end

    def create
      @evaluator = @current_case.evaluators.new(evaluator_params)

      if @evaluator.save
        log_evaluator_added
        redirect_to support_case_evaluators_path(case_id: @current_case),
                    notice: I18n.t("support.case_evaluators.flash.success", name: @evaluator.name)
      else
        render :new
      end
    end

    def edit; end

    def update
      if @evaluator.update(evaluator_params)
        log_evaluator_updated
        redirect_to support_case_evaluators_path(case_id: @current_case),
                    notice: I18n.t("support.case_evaluators.flash.updated", name: @evaluator.name)
      else
        render :edit
      end
    end

    def destroy
      return unless params[:confirm]

      @evaluator.destroy!
      log_evaluator_removed
      redirect_to support_case_evaluators_path(case_id: @current_case),
                  notice: I18n.t("support.case_evaluators.flash.destroyed", name: @evaluator.name)
    end

  private

    def set_evaluator
      @evaluator = current_case.evaluators.find(params[:id])
    end

    def set_current_case
      @current_case = Support::Case.find(params[:case_id])
    end

    def evaluator_params
      params.require(:support_evaluator).permit(:first_name, :last_name, :email)
    end

    def log_evaluator_added
      body = "Evaluator #{@evaluator.name} added by #{Current.agent.first_name} #{Current.agent.last_name}"
      additional_data = { event: "new", evaluator_id: @evaluator.id, first_name: @evaluator.first_name, last_name: @evaluator.last_name, email: @evaluator.email }
      Support::EvaluationJourneyTracking.new(:evaluator_added, params[:case_id], body, additional_data).call
    end

    def log_evaluator_updated
      return unless @evaluator.saved_changes?

      from_first_name = @evaluator.saved_changes["first_name"]&.first || @evaluator.first_name
      to_first_name = @evaluator.saved_changes["first_name"]&.last || @evaluator.first_name

      from_last_name = @evaluator.saved_changes["last_name"]&.first || @evaluator.last_name
      to_last_name = @evaluator.saved_changes["last_name"]&.last || @evaluator.last_name

      from_email = @evaluator.saved_changes["email"]&.first || @evaluator.email
      to_email = @evaluator.saved_changes["email"]&.last || @evaluator.email

      old_name = [from_first_name, from_last_name].compact.join(" ")
      new_name = [to_first_name, to_last_name].compact.join(" ")

      if @evaluator.saved_change_to_first_name? || @evaluator.saved_change_to_last_name?
        body = "Evaluator #{old_name} changed to #{new_name} by #{Current.agent.first_name} #{Current.agent.last_name}"
        additional_data = {
          event: "modify",
          evaluator_id: @evaluator.id,
          from: { first_name: from_first_name, last_name: from_last_name },
          to: { first_name: to_first_name, last_name: to_last_name },
        }
        Support::EvaluationJourneyTracking.new(:evaluator_updated, params[:case_id], body, additional_data).call
      end

      if @evaluator.saved_change_to_email?
        body = "Evaluator email for #{new_name} updated by #{Current.agent.first_name} #{Current.agent.last_name}"
        additional_data = {
          event: "modify",
          evaluator_id: @evaluator.id,
          from: { email: from_email },
          to: { email: to_email },
        }
        Support::EvaluationJourneyTracking.new(:evaluator_updated, params[:case_id], body, additional_data).call
      end
    end

    def log_evaluator_removed
      body = "Evaluator #{@evaluator.name} removed by #{Current.agent.first_name} #{Current.agent.last_name}"
      additional_data = { event: "remove", first_name: @evaluator.first_name, last_name: @evaluator.last_name, email: @evaluator.email, evaluator_id: @evaluator.id }
      Support::EvaluationJourneyTracking.new(:evaluator_updated, params[:case_id], body, additional_data).call
    end
  end
end
