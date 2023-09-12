class Frameworks::Management::ActivityLogsController < Frameworks::Management::ApplicationController
  before_action { @back_url = frameworks_management_path }

  def show
    @activity_log_items = Frameworks::ActivityLogItem.paginate(page: params[:page], per_page: 50)
  end

private

  def authorize_agent_scope = [super, :manage_frameworks_activity_log?]
end
