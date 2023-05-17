module Support
  class Management::AllCasesSurveysController < ::Support::Management::BaseController
    def create
      case_refs = form_params["eligible_cases"].split(/(?:\r?\n)+/)
      case_refs.each { |ref| Support::SendAllCasesSurveyJob.perform_later(ref) }

      redirect_to support_management_path, notice: I18n.t("support.management.all_cases_surveys.notice")
    end

  private

    def authorize_agent_scope = [super, :access_proc_ops_portal?]

    def form_params
      params.require(:eligible_cases_form).permit(:eligible_cases)
    end
  end
end
