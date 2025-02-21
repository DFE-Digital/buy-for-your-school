class Frameworks::FrameworksController < Frameworks::ApplicationController
  before_action :redirect_to_register_tab, unless: :turbo_frame_request?, only: :index
  before_action :load_form_options, only: %i[new edit create update]

  def new
    @framework = Frameworks::Framework.new
  end

  def edit
    @framework = Frameworks::Framework.find(params[:id])
  end

  def index
    @filtering = Frameworks::Framework.filtering(filter_form_params)
    @frameworks = @filtering.results.paginate(page: params[:frameworks_page])
  end

  def show
    @framework = Frameworks::Framework.find(params[:id])
    @activity_log_items = @framework.activity_log_items.paginate(page: params[:activities_page])
  end

  def create
    @framework = Frameworks::Framework.new(framework_params)
    @framework.source = :register

    if @framework.save(context: :creation_form)
      redirect_to frameworks_framework_path(@framework)
    else
      render :new
    end
  end

  def update
    @framework = Frameworks::Framework.find(params[:id])
    @framework.assign_attributes(framework_params)

    if @framework.save(context: :updation_form)
      redirect_to frameworks_framework_path(@framework)
    else
      render :edit
    end
  end

private

  def load_form_options
    @procops_agents = Support::Agent.caseworkers
    @e_and_o_agents = Support::Agent.e_and_o_staff
    @providers = Frameworks::Provider.all.order(:short_name)
    @provider_contacts = Frameworks::ProviderContact.all.order(:name)
  end

  def filter_form_params
    params.fetch(:frameworks_filter, {}).permit(
      :sort_by, :sort_order,
      :omnisearch,
      status: [], provider: [],
      e_and_o_lead: [], proc_ops_lead: [],
      category: [], provider_contact: []
    )
  end

  def framework_params
    params.require(:frameworks_framework).permit(
      :name, :short_name, :url, :provider_reference,
      :sct_framework_provider_lead, :sct_framework_owner, :proc_ops_lead_id, :e_and_o_lead_id,
      :dfe_start_date, :dfe_review_date, :provider_start_date, :provider_end_date,
      :faf_added_date, :faf_end_date,
      :dps, :lot,
      :provider_id, :provider_contact_id,
      :status
    )
  end

  def redirect_to_register_tab
    redirect_to frameworks_root_path(anchor: "frameworks-register", **request.params.except(:controller, :action))
  end
end
