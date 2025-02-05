module Support
  class Cases::ReviewEvaluationsController < Cases::ApplicationController
    before_action :set_current_case
    before_action :set_evaluation_files
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

    def set_evaluation_files
      @evaluation_files = Support::EvaluatorsUploadDocument.where(support_case_id: params[:case_id])
    end

    def reset_evaluation_approvals
      Support::Evaluator.where(support_case_id: params[:case_id]).update_all(evaluation_approved: false)
    end

    def approve_selected_evaluations
      filtered_params = filter_blank_evaluations(review_evaluations_params)
      Support::Evaluator.where(email: filtered_params[:evaluation_approved]).update_all(evaluation_approved: true)
    end

    def evaluation_pending?
      @current_case.evaluators.where(evaluation_approved: false).any?
    end

    def update_procurement_stage_if_needed
      moderation_stage = if evaluation_pending?
                           Support::ProcurementStage.find_by(stage: "3", title: "Stage 3 Evaluation")
                         else
                           Support::ProcurementStage.find_by(stage: "3", title: "Moderation")
                         end
      @current_case.update!(procurement_stage_id: moderation_stage.id) if moderation_stage
    end

    def review_evaluations_params
      params.require(:review_evaluations_form).permit(evaluation_approved: [])
    end

    def filter_blank_evaluations(params)
      params[:evaluation_approved] = params[:evaluation_approved].reject(&:blank?)
      params
    end
  end
end
