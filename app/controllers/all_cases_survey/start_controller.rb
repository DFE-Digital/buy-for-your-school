module AllCasesSurvey
  class StartController < BaseController
    before_action :case_ref, only: %i[show]

    def show; end

    def case_ref
      @case_ref ||= form.case_ref
    end
  end
end
