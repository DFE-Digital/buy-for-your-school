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
      update_action_required
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
      Support::EvaluationJourneyTracking.new(:evaluator_added, @evaluator).call
    end

    def log_evaluator_updated
      return unless @evaluator.saved_changes?

      Support::EvaluationJourneyTracking.new(:evaluator_updated, @evaluator).call
    end

    def log_evaluator_removed
      Support::EvaluationJourneyTracking.new(:evaluator_removed, @evaluator).call
    end

    def update_action_required
      pending_evaluations = @current_case.evaluators.where(has_uploaded_documents: true, evaluation_approved: false).any?
      unread_emails = Support::Email.where(ticket_id: @current_case.id, folder: 0, is_read: false).any?
      action_required = pending_evaluations || unread_emails
      @current_case.update!(action_required:)
    end
  end
end
