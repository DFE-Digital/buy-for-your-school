module Support
  class CaseStatistics::TowersController < ::Support::CaseStatisticsController
    def show
      @tower_statistics = Support::TowerStatistics.new(tower_slug: params[:id])
    end
  end
end
