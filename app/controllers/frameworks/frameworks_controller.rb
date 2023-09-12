class Frameworks::FrameworksController < Frameworks::ApplicationController
  before_action :redirect_to_register_tab, unless: :turbo_frame_request?, only: :index
  before_action :set_back_url, only: %i[new show]

  def new; end

  def index
    @filtering = Frameworks::Framework.filtering(filter_form_params)
    @frameworks = @filtering.results.paginate(page: params[:frameworks_page])
  end

  def show
    @framework = Frameworks::Framework.find(params[:id])
    @activity_log_items = @framework.activity_log_items.paginate(page: params[:activities_page])
  end

private

  def filter_form_params
    params.fetch(:frameworks_filter, {}).permit(
      :sort_by, :sort_order,
      status: [], provider: [],
      e_and_o_lead: [], proc_ops_lead: [],
      category: [], provider_contact: []
    )
  end

  def set_back_url
    @back_url = back_link_param
  end

  def redirect_to_register_tab
    redirect_to frameworks_root_path(anchor: "frameworks-register", **request.params.except(:controller, :action))
  end
end
