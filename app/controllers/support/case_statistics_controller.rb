module Support
  class CaseStatisticsController < ApplicationController
    skip_before_action :authenticate_agent!
    before_action :authenticate_agent_or_analyst!

    def show
      respond_to do |format|
        format.html do
          @case_statistics = Support::CaseStatistics.new
        end

        format.csv do
          Rollbar.info("Case data downloaded.")
          send_data CaseDatum.to_csv, filename: "case_data.csv", type: "text/csv"
        end
      end
    end

  private

    def authenticate_agent_or_analyst!
      return if current_agent

      return render "errors/missing_role" unless current_user.analyst?
    end
  end
end
