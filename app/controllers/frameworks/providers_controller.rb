class Frameworks::ProvidersController < Frameworks::ApplicationController
  before_action :redirect_to_register_tab, unless: :turbo_frame_request?, only: :index
  before_action :set_back_url, only: %i[new show]

  def index
    @filtering = Frameworks::Provider.filtering(filter_form_params)
    @providers = @filtering.results.paginate(page: params[:providers_page])
  end

  def show
    @provider = Frameworks::Provider.find(params[:id])
    @activity_log_items = @provider.activity_log_items.paginate(page: params[:activities_page])
  end

private

  def filter_form_params
    params.fetch(:providers_filter, {}).permit(
      :sort_by, :sort_order
    )
  end

  def redirect_to_register_tab
    redirect_to frameworks_root_path(anchor: "providers", **request.params.except(:controller, :action))
  end
end
