module Support
  class CaseStatisticsController < ApplicationController
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

    def authorize_agent_scope = :access_statistics?
  end
end
