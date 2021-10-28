module Support
  class Cases::ApplicationController < ApplicationController
    before_action :current_case

  private

    def current_case
      @current_case ||= CasePresenter.new(Case.find_by(id: params[:case_id]))
    end
  end
end
