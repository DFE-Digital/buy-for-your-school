class Frameworks::Management::RegisterUploadsController < Frameworks::Management::ApplicationController
  before_action { @back_url = frameworks_management_path }

  def new; end

  def create
    Frameworks::Framework.import_from_spreadsheet(register_upload_params[:spreadsheet])

    redirect_to frameworks_management_path
  end

private

  def register_upload_params
    params.require(:register_upload).permit(:spreadsheet)
  end

  def authorize_agent_scope = [super, :manage_frameworks_register_upload?]
end
