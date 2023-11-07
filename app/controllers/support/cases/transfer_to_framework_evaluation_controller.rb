module Support
  class Cases::TransferToFrameworkEvaluationController < Cases::ApplicationController
    before_action :back_url
    before_action :set_form_options, only: %i[index create]

    def index
      @case_transferer = current_case.transferer
    end

    def create
      @case_transferer = current_case.transferer(form_params)

      if @case_transferer.valid?
        evaluation = @case_transferer.save!
        redirect_to frameworks_evaluation_path(evaluation), notice: "Case transferred"
      else
        render :index
      end
    end

  private

    def back_url
      @back_url = support_case_path(@current_case)
    end

    def set_form_options
      @frameworks = ::Frameworks::Framework.for_evaluation
      @agents = Support::Agent.framework_evaluators
    end

    def form_params
      params.require(:case_transferer).permit(:framework_id, :assignee_id)
    end
  end
end
