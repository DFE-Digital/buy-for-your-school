class Frameworks::ProvidersController < Frameworks::ApplicationController
  before_action :redirect_to_register_tab, unless: :turbo_frame_request?, only: :index

  def index
    @filtering = Frameworks::Provider.filtering(filter_form_params)
    @providers = @filtering.results.paginate(page: params[:providers_page])
  end

  def show
    @provider = Frameworks::Provider.find(params[:id])
    @activity_log_items = @provider.activity_log_items.paginate(page: params[:activities_page])
  end

  def new
    @provider = Frameworks::Provider.new
  end

  def edit
    @provider = Frameworks::Provider.find(params[:id])
  end

  def create
    @provider = Frameworks::Provider.new(provider_params)

    if @provider.save
      redirect_to frameworks_provider_path(@provider)
    else
      render :new
    end
  end

  def update
    @provider = Frameworks::Provider.find(params[:id])

    if @provider.update(provider_params)
      redirect_to frameworks_provider_path(@provider)
    else
      render :edit
    end
  end

private

  def provider_params
    params.require(:frameworks_provider).permit(:name, :short_name)
  end

  def filter_form_params
    params.fetch(:providers_filter, {}).permit(
      :sort_by, :sort_order
    )
  end

  def redirect_to_register_tab
    redirect_to frameworks_root_path(anchor: "providers", **request.params.except(:controller, :action))
  end
end
