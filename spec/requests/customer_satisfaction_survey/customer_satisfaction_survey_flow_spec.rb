require "rails_helper"

describe "Filling out a customer satisfaction survey" do
  let(:post_params) { { service: "create_a_spec" } }
  let!(:survey) do
    post customer_satisfaction_surveys_path, params: post_params
    CustomerSatisfactionSurveyResponse.last
  end

  describe "Starting a new survey" do
    it "creates a new survey and redirects to the first question" do
      expect {
        post customer_satisfaction_surveys_path, params: post_params
      }.to change(CustomerSatisfactionSurveyResponse, :count).by(1)

      expect(response).to redirect_to(edit_customer_satisfaction_surveys_recommendation_likelihood_path(CustomerSatisfactionSurveyResponse.last))

      survey = CustomerSatisfactionSurveyResponse.last
      expect(survey.in_progress?).to eq(true)
      expect(survey.survey_started_at).to be_within(1.second).of(Time.zone.now)
    end
  end

  describe "Accessing a completed survey" do
    let!(:survey) { create(:customer_satisfaction_survey_response, status: :completed) }

    before { get edit_customer_satisfaction_surveys_recommendation_likelihood_path(survey) }

    it "redirects to the final page with a notice" do
      expect(response).to redirect_to(customer_satisfaction_surveys_thank_you_path)
      expect(flash[:notice]).to eq("Survey already completed")
    end
  end

  describe "Answering the questions" do
    let!(:survey) { create(:customer_satisfaction_survey_response) }

    describe "Answering 'Overall, how satisfied are you with this service?'" do
      let(:params) { {} }

      before { patch customer_satisfaction_surveys_satisfaction_level_path(survey), params: }

      context "when valid" do
        context "and the survey is created for an exit survey email" do
          let!(:survey) { create(:customer_satisfaction_survey_response, source: :exit_survey) }
          let(:params) { { customer_satisfaction_survey: { satisfaction_level: "neither" } } }

          it "persists the answer" do
            expect(survey.reload.satisfaction_level).to eq("neither")
          end

          it "redirects to the next question" do
            expect(response).to redirect_to(edit_customer_satisfaction_surveys_satisfaction_reason_path(survey))
          end
        end

        context "and the survey is created via banner link" do
          let!(:survey) { create(:customer_satisfaction_survey_response, source: :banner_link) }
          let(:params) { { customer_satisfaction_survey: { satisfaction_level: "neither", satisfaction_text_neither: "reason" } } }

          it "persists the answer and reason" do
            expect(survey.reload.satisfaction_level).to eq("neither")
            expect(survey.reload.satisfaction_text).to eq("reason")
          end
        end
      end

      context "when invalid" do
        let(:params) { {} }

        it "renders the same page" do
          expect(response).not_to redirect_to(edit_customer_satisfaction_surveys_satisfaction_reason_path(survey))
          expect(response).to render_template("edit")
        end
      end
    end

    describe "Answering 'Please tell us why you gave that score'" do
      let(:params) { { customer_satisfaction_survey: { satisfaction_text: "reasons" } } }

      before { patch customer_satisfaction_surveys_satisfaction_reason_path(survey), params: }

      it "persists the answer" do
        expect(survey.reload.satisfaction_text).to eq("reasons")
      end

      it "completes the survey" do
        expect(survey.reload.completed?).to eq(true)
        expect(survey.reload.survey_completed_at).to be_within(1.second).of(Time.zone.now)
      end
    end

    describe "Answering 'This service was easy to use'" do
      let(:params) { {} }

      before { patch customer_satisfaction_surveys_easy_to_use_rating_path(survey), params: }

      context "when valid" do
        let(:params) { { customer_satisfaction_survey: { easy_to_use_rating: "disagree" } } }

        it "persists the answer" do
          expect(survey.reload.easy_to_use_rating).to eq("disagree")
        end
      end

      context "when invalid" do
        let(:params) { {} }

        it "renders the same page" do
          expect(response).not_to redirect_to(edit_customer_satisfaction_surveys_helped_how_path(survey))
          expect(response).to render_template("edit")
        end
      end
    end

    describe "Answering 'How has this service helped you?'" do
      let(:params) { {} }

      before { patch customer_satisfaction_surveys_helped_how_path(survey), params: }

      context "when valid" do
        let(:params) { { customer_satisfaction_survey: { helped_how: %w[saved_money saved_time] } } }

        it "persists the answer" do
          expect(survey.reload.helped_how).to eq(%w[saved_money saved_time])
        end
      end

      context "when invalid" do
        let(:params) { {} }

        it "renders the same page" do
          expect(response).not_to redirect_to(edit_customer_satisfaction_surveys_clear_to_use_rating_path(survey))
          expect(response).to render_template("edit")
        end
      end
    end

    describe "Answering 'It was clear to me what I could use this service to do'" do
      let(:params) { {} }

      before { patch customer_satisfaction_surveys_clear_to_use_rating_path(survey), params: }

      context "when valid" do
        let(:params) { { customer_satisfaction_survey: { clear_to_use_rating: "agree" } } }

        it "persists the answer" do
          expect(survey.reload.clear_to_use_rating).to eq("agree")
        end
      end

      context "when invalid" do
        let(:params) { {} }

        it "renders the same page" do
          expect(response).not_to redirect_to(edit_customer_satisfaction_surveys_recommendation_likelihood_path(survey))
          expect(response).to render_template("edit")
        end
      end
    end

    describe "Answering 'On a scale of 0 to 10, how likely are you to recommend us to a colleague?'" do
      let(:params) { {} }

      before { patch customer_satisfaction_surveys_recommendation_likelihood_path(survey), params: }

      context "when valid" do
        let(:params) { { customer_satisfaction_survey: { recommendation_likelihood: "7" } } }

        it "persists the answer" do
          expect(survey.reload.recommendation_likelihood).to eq(7)
        end
      end

      context "when invalid" do
        let(:params) { {} }

        it "renders the same page" do
          expect(response).not_to redirect_to(edit_customer_satisfaction_surveys_improvements_path(survey))
          expect(response).to render_template("edit")
        end
      end
    end

    describe "Answering 'Please tell us how we could improve this service'" do
      let(:params) { { customer_satisfaction_survey: { improvements: "various improvements" } } }

      before { patch customer_satisfaction_surveys_improvements_path(survey), params: }

      it "persists the answer" do
        expect(survey.reload.improvements).to eq("various improvements")
      end
    end

    describe "Answering 'Would you like to participate in research?'" do
      let(:params) { {} }

      before { patch customer_satisfaction_surveys_research_opt_in_path(survey), params: }

      context "when valid" do
        let(:params) { { customer_satisfaction_survey: { research_opt_in: false } } }

        it "persists the answer" do
          expect(survey.reload.research_opt_in).to eq(false)
          expect(survey.reload.research_opt_in_email).to be_nil
          expect(survey.reload.research_opt_in_job_title).to be_nil
        end
      end
    end
  end
end
