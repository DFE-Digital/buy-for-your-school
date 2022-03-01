module Support
  class AdminController < ApplicationController
    skip_before_action :authenticate_agent!
    before_action :authenticate_agent_or_analyst!
    before_action :set_view_fields, only: :show

    def show
      role =  if current_user.analyst?
                "analyst"
              else
                "agent"
              end

      Rollbar.info("User role has been granted access.", role: role, path: request.path)
    end

    def download_cases
      respond_to do |format|
        format.csv do
          Rollbar.info("Case data downloaded.")
          send_data CaseDatum.to_csv, filename: "case_data.csv", type: "text/csv"
        end
      end
    end

  private

    def set_view_fields
      @no_of_cases = Case.count
      @no_of_cases_by_state = Case.group(:state).count
      @no_of_cases_by_state_and_category = Case.order(:state).group(:state, :category_id).count
      @categories = Case.joins(:category).select("support_categories.id, support_categories.title").order("support_categories.title").uniq
      @states = Case.states.first(5).to_h.keys
    end

    # @return [nil]
    def authenticate_agent_or_analyst!
      return if current_agent

      return render "errors/missing_role" unless current_user.analyst?
    end
  end
end
