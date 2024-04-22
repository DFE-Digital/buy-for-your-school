class Frameworks::DashboardsController < Frameworks::ApplicationController
  before_action { @back_url = nil }

  def index
    respond_to do |format|
      format.html
      format.csv do
        send_data Frameworks::FrameworkDatum.to_csv, filename: "frameworks_data.csv", type: "text/csv"
      end
    end
  end
end
