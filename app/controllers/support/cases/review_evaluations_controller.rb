module Support
  class Cases::ReviewEvaluationsController < Cases::ApplicationController
    before_action :set_current_case
    before_action :set_evalution_files
    before_action { @back_url = support_case_path(@current_case, anchor: "tasklist") }

    def edit; end

    def update
      reset_evaluation_approvals
      approve_selected_evaluations
      update_procurement_stage_if_needed

      redirect_to @back_url
    end

  private

    def set_current_case
      @current_case = Support::Case.find(params[:case_id])
    end

    def set_current_evaluator
      @current_evaluator = Support::Evaluator.find(params[:case_id])
    end

    def set_evalution_files
      @evalution_files = Support::EvaluatorsUploadDocument.where(support_case_id: params[:case_id])
    end

    def reset_evaluation_approvals
      Support::Evaluator.where(support_case_id: params[:case_id]).update_all(evaluation_approved: false)
    end

    def approve_selected_evaluations
      Support::Evaluator.where(email: review_evaluation_params[:evaluation_approved]).update_all(evaluation_approved: true)
    end

    def update_procurement_stage_if_needed
      evaluation_count = @current_case.evaluators.all.count(&:evaluation_approved)

      moderation_stage = if @current_case.evaluators.count == evaluation_count
                           Support::ProcurementStage.find_by(stage: "3", title: "Moderation")
                         else
                           Support::ProcurementStage.find_by(stage: "3", title: "Stage 3 Evaluation")
                         end
      @current_case.update!(procurement_stage_id: moderation_stage.id) if moderation_stage
    end

    def review_evaluation_params
      params.require(:review_evaluations_form).permit(evaluation_approved: []).tap do |whitelisted|
        whitelisted[:evaluation_approved].reject!(&:blank?) if whitelisted[:evaluation_approved].is_a?(Array)
      end
    end
  end
end
