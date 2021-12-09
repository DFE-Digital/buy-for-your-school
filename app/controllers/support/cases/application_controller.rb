module Support
  class Cases::ApplicationController < ApplicationController
    before_action :current_case

  private

    # @return [Case, nil]
    def current_case
      @current_case ||= Case.find_by(id: params[:case_id])
    end

    # @return [AgentPresenter, nil]
    def current_agent
      AgentPresenter.new(super) if super
    end
  end
end
