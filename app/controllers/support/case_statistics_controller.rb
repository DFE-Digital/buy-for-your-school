module Support
  class CaseStatisticsController < ApplicationController
    def show
      respond_to do |format|
        format.html do
          @live_cases = Support::Case.live
          @triage_cases = @live_cases.triage

          @towers = Support::Tower.unique_towers
          @live_statuses = %w[live opened on_hold initial]
          @support_levels = Support::Case.support_levels
          @triage_levels = Support::Case.triage_levels
          @top_level_stages = Support::ProcurementStage.stages

          store_selected_caseworker(params[:selected_caseworker]) unless params[:selected_caseworker].nil?
          @selected_caseworker = Support::Agent.find_by(id: session[:stats_selected_caseworker])
          @caseworkers_to_display = @selected_caseworker.nil? ? Support::Agent.caseworkers.by_first_name : [@selected_caseworker]
        end

        format.csv do
          track_event("CaseStatistics/CsvDownloaded")
          send_data CaseDatum.to_csv, filename: "case_data.csv", type: "text/csv"
        end
      end
    end

    def substages_for_stage(parent)
      Support::ProcurementStage.substages_for_stage(parent)
    end
    helper_method :substages_for_stage

  private

    def store_selected_caseworker(agent_id)
      session[:stats_selected_caseworker] = agent_id == "all" ? nil : agent_id
    end

    def authorize_agent_scope = :access_statistics?
  end
end
