module Support
  class TowersController < CaseStatisticsController
    before_action :set_tower_view_fields, only: :show

    def show; end

  private

    def set_tower_view_fields
      @stages = Procurement.stages.to_h.keys
      @levels = Case.support_levels.to_h.keys
      @no_of_live_cases_by_tower_state_and_stage = Tower.group(:procops_tower, :state, :stage).count
      @no_of_live_cases_by_tower_state_and_level = Tower.group(:procops_tower, :state, :support_level).count
    end
  end
end
