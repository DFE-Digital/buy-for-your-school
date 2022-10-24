module Support
  class CaseStatistics::TowersController < ::Support::CaseStatisticsController
    def show
      @tower_statistics = Support::TowerStatistics.new(tower_slug: params[:id])
      @back_url = support_case_statistics_path
    end
  end
end
