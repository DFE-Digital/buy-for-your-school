module Support
  class CaseStatisticsController < ApplicationController
    skip_before_action :authenticate_agent!
    before_action :authenticate_agent_or_analyst!
    before_action :set_view_fields, only: :show

    def show
      respond_to do |format|
        format.html do
          role =  if current_user.analyst?
                    "analyst"
                  else
                    "agent"
                  end

          Rollbar.info("User role has been granted access.", role:, path: request.path)
        end

        format.csv do
          Rollbar.info("Case data downloaded.")
          send_data CaseDatum.to_csv, filename: "case_data.csv", type: "text/csv"
        end
      end
    end

  private

    def set_view_fields
      @no_of_live_cases = Case.where(state: %i[initial opened on_hold]).count
      @no_of_live_cases_by_state = Case.where(state: %i[initial opened on_hold]).group(:state).count
      @no_of_live_cases_by_tower = Case.where(state: %i[initial opened on_hold]).left_outer_joins(:category).group(:tower).count("support_cases.id")
      @no_of_live_cases_by_tower_and_state = Case.where(state: %i[initial opened on_hold]).left_outer_joins(:category).group(:tower, :state).count("support_cases.id")
      @categories = Case.joins(:category).select("support_categories.title").order("support_categories.title").uniq
      @towers = Category.unique_towers
      @states = Case.states.first(5).to_h.keys
      @live_states = %w[opened on_hold initial]
    end

    # @return [nil]
    def authenticate_agent_or_analyst!
      return if current_agent

      return render "errors/missing_role" unless current_user.analyst?
    end
  end
end
