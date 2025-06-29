describe CustomerSatisfactionSurveys::EasyToUseRatingsController, type: :controller do
  describe "back url" do
    context "when the survey is created for an exit survey email" do
      let(:survey) { create(:customer_satisfaction_survey_response, source: :exit_survey) }

      before { get :edit, params: { id: survey.id } }

      it "goes back to the satisfaction reason question" do
        controller.set_service("create_a_spec")
        back_url = controller.get_flow.back_path
        expect(back_url).to eq "edit_customer_satisfaction_surveys_improvements_path"
      end
    end

    context "when the survey is created via banner link" do
      let(:survey) { create(:customer_satisfaction_survey_response, source: :banner_link) }

      before { get :edit, params: { id: survey.id } }

      it "goes back to the satisfaction level question" do
        controller.set_service("create_a_spec")
        back_url = controller.get_flow.back_path
        expect(back_url).to eq "edit_customer_satisfaction_surveys_improvements_path"
      end
    end
  end
end
