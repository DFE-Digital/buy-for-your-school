module Support
  class Cases::EvaluatorsController < Cases::ApplicationController
    before_action :set_current_case
    before_action :set_evaluator, only: %i[edit update destroy]

    def index
      @evaluators = @current_case.evaluators.all
    end

    def new
      @evaluator = @current_case.evaluators.new
    end

    def create
      @evaluator = @current_case.evaluators.new(evaluator_params)

      if @evaluator.save
        redirect_to support_case_evaluators_path(case_id: @current_case),
                    notice: I18n.t("support.case_evaluators.flash.success", name: @evaluator.name)
      else
        render :new
      end
    end

    def edit; end

    def update
      if @evaluator.update(evaluator_params)
        redirect_to support_case_evaluators_path(case_id: @current_case),
                    notice: I18n.t("support.case_evaluators.flash.updated", name: @evaluator.name)
      else
        render :edit
      end
    end

    def destroy
      return unless params[:confirm]

      @evaluator.destroy!
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
  end
end
