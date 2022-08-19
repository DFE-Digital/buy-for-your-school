module Support
  class TowersController < CaseStatisticsController
    before_action :set_tower_view_fields, only: :show

    def show; end

  private

    def set_tower_view_fields
      @stages = Procurement.stages.to_h
      @levels = Case.support_levels.to_h.keys
      @no_of_live_cases_by_tower_state_and_stage = Case.where(state: %i[initial opened on_hold]).left_outer_joins(:category, :procurement).group(:tower, :state, :stage).count("support_cases.id")
      @no_of_live_cases_by_tower_state_and_level = Case.where(state: %i[initial opened on_hold]).left_outer_joins(:category).group(:tower, :state, :support_level).count("support_cases.id")
    end
  end
end
