module Support
  class CaseStatistics::TowersController < ::Support::CaseStatisticsController
    def show
      @tower_statistics = Support::TowerStatistics.new(tower_slug: params[:id])
      @tower = Support::Tower.find(@tower_statistics.tower_id) if @tower_statistics.tower_id.present?
      @back_url = support_case_statistics_path
    end
  end
end
