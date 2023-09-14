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

    if @framework.save(context: :creation_form)
      redirect_to frameworks_framework_path(@framework)
    else
      render :new
    end
  end

  def update
    @framework = Frameworks::Framework.find(params[:id])

    if @framework.update(framework_params)
      redirect_to frameworks_framework_path(@framework)
    else
      render :edit
    end
  end

private

  def load_form_options
    @providers = Frameworks::Provider.all
    @provider_contacts = Frameworks::ProviderContact.all
  end

  def filter_form_params
    params.fetch(:frameworks_filter, {}).permit(
      :sort_by, :sort_order,
      status: [], provider: [],
      e_and_o_lead: [], proc_ops_lead: [],
      category: [], provider_contact: []
    )
  end

  def framework_params
    params.require(:frameworks_framework).permit(
      :name, :short_name, :url, :reference,
      :dfe_start_date, :dfe_end_date, :provider_start_date, :provider_end_date,
      :dps, :lot,
      :provider_id, :provider_contact_id,
      :status
    )
  end

  def redirect_to_register_tab
    redirect_to frameworks_root_path(anchor: "frameworks-register", **request.params.except(:controller, :action))
  end
end
