class Frameworks::EvaluationsController < Frameworks::ApplicationController
  before_action :redirect_to_register_tab, unless: :turbo_frame_request?, only: :index
  before_action :set_form_options, only: %i[new edit create update]

  content_security_policy do |policy|
    policy.style_src_attr :unsafe_inline
  end

  def index
    @filtering = Frameworks::Evaluation.filtering(filter_form_params)
    @evaluations = @filtering.results.paginate(page: params[:evaluations_page])
  end

  def show
    @evaluation = Frameworks::Evaluation.find(params[:id])
    @activity_log_items = @evaluation.activity_log_items.order("created_at DESC").paginate(page: params[:activity_log_page])
  end

  def new
    @evaluation = Frameworks::Evaluation.new(framework_id: params[:framework_id])
  end

  def create
    @evaluation = Frameworks::Evaluation.new(evaluation_params)

    if @evaluation.save
      redirect_to @evaluation
    else
      render :new
    end
  end

  def edit
    @evaluation = Frameworks::Evaluation.find(params[:id])
  end

  def update
    @evaluation = Frameworks::Evaluation.find(params[:id])

    if @evaluation.update(evaluation_params)
      redirect_to @evaluation
    else
      render :edit
    end
  end

private

  def set_form_options
    @frameworks = Frameworks::Framework.for_evaluation
    @agents = Support::Agent.framework_evaluators
    @contacts = Frameworks::ProviderContact.all
  end

  def filter_form_params
    params.fetch(:evaluations_filter, {}).permit(
      :sort_by, :sort_order,
      status: [], provider: [], assignee: [], category: []
    )
  end

  def evaluation_params
    params.require(:frameworks_evaluation).permit(:framework_id, :assignee_id, :contact_id)
  end

  def redirect_to_register_tab
    redirect_to frameworks_root_path(anchor: "evaluations", **request.params.except(:controller, :action))
  end
end
