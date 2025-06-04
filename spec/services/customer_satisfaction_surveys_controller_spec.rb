require "rails_helper"

  describe CustomerSatisfactionSurveysController, type: :controller do
    let(:find_a_framework_flow) { %w[recommendation_likelihood improvement easy_to_use_rating helped_how clear_to_use_rating research_opt_in satisfaction_level thank_you]}
    let(:create_a_spec_flow) { %w[recommendation_likelihood improvement easy_to_use_rating helped_how clear_to_use_rating research_opt_in satisfaction_level thank_you]}
    let(:supported_journey_flow) { %w[recommendation_likelihood improvement easy_to_use_rating helped_how clear_to_use_rating research_opt_in satisfaction_level thank_you]}
    let(:request_for_help_form_flow) { %w[recommendation_likelihood improvement easy_to_use_rating helped_how clear_to_use_rating research_opt_in satisfaction_level thank_you]}
    let(:find_a_buying_solution_flow) { %w[satisfaction_level easy_to_use_rating helped_how clear_to_use_rating recommendation_likelihood improvement thank_you]}

    describe "questions_flow" do
      context "when the customer survey is created for find_a_buying_solution" do
        let(:survey) { create(:customer_satisfaction_survey_response, source: :exit_survey) }
        it "goes back to the first customer satisfaction question" do
          controller.set_service("find_a_buying_solution")
          flow = controller.get_flow
          current_path =  controller.get_flow.current_path
          back_url = controller.get_flow.back_path
          next_path = controller.get_flow.next_path

          expect(current_path).to eq "edit_customer_satisfaction_surveys_satisfaction_level_path"
          expect(next_path).to eq "edit_customer_satisfaction_surveys_easy_to_use_rating_path"
          expect(back_url).to be_nil
          expect(flow.all_steps).to eq find_a_buying_solution_flow
          expect(flow.all_steps).not_to eq create_a_spec_flow
        end
      end

      context "when the customer survey is created for find_a_framework_flow" do
        let(:survey) { create(:customer_satisfaction_survey_response, source: :exit_survey) }
        it "goes back to the first customer satisfaction question" do
          controller.set_service("find_a_framework")
          flow = controller.get_flow
          current_path =  controller.get_flow.current_path
          back_url = controller.get_flow.back_path
          next_path = controller.get_flow.next_path

          expect(current_path).to eq "edit_customer_satisfaction_surveys_recommendation_likelihood_path"
          expect(next_path).to eq "edit_customer_satisfaction_surveys_improvements_path"
          expect(back_url).to be_nil
          expect(flow.all_steps).to eq find_a_framework_flow
        end
      end
    end

    context "when the customer survey is created for create_a_spec" do
      let(:survey) { create(:customer_satisfaction_survey_response, source: :exit_survey) }
      it "goes back to the first customer satisfaction question" do
        controller.set_service("create_a_spec")
        flow = controller.get_flow
        current_path =  controller.get_flow.current_path
        back_url = controller.get_flow.back_path
        next_path = controller.get_flow.next_path

        expect(current_path).to eq "edit_customer_satisfaction_surveys_recommendation_likelihood_path"
        expect(next_path).to eq "edit_customer_satisfaction_surveys_improvements_path"
        expect(back_url).to be_nil
        expect(flow.all_steps).to eq create_a_spec_flow
      end
    end

    context "when the customer survey is created for supported_journey" do
      let(:survey) { create(:customer_satisfaction_survey_response, source: :exit_survey) }
      it "goes back to the first customer satisfaction question" do
        controller.set_service("supported_journey")
        flow = controller.get_flow
        current_path =  controller.get_flow.current_path
        back_url = controller.get_flow.back_path
        next_path = controller.get_flow.next_path

        expect(current_path).to eq "edit_customer_satisfaction_surveys_recommendation_likelihood_path"
        expect(next_path).to eq "edit_customer_satisfaction_surveys_improvements_path"
        expect(back_url).to be_nil
        expect(flow.all_steps).to eq supported_journey_flow
      end
    end

    context "when the customer survey is created for request_for_help_form" do
      let(:survey) { create(:customer_satisfaction_survey_response, source: :exit_survey) }
      it "goes back to the first customer satisfaction question" do
        controller.set_service("request_for_help_form")
        flow = controller.get_flow
        current_path =  controller.get_flow.current_path
        back_url = controller.get_flow.back_path
        next_path = controller.get_flow.next_path

        expect(current_path).to eq "edit_customer_satisfaction_surveys_recommendation_likelihood_path"
        expect(next_path).to eq "edit_customer_satisfaction_surveys_improvements_path"
        expect(back_url).to be_nil
        expect(flow.all_steps).to eq request_for_help_form_flow
      end
    end

    context "when the customer survey is created for request_for_help_form" do
      let(:survey) { create(:customer_satisfaction_survey_response, source: :exit_survey) }
      it "goes back to the first customer satisfaction question" do
        controller.set_service("request_for_help_form")
        flow = controller.get_flow
        current_path =  controller.get_flow.current_path
        back_url = controller.get_flow.back_path
        next_path = controller.get_flow.next_path

        expect(current_path).to eq "edit_customer_satisfaction_surveys_recommendation_likelihood_path"
        expect(next_path).to eq "edit_customer_satisfaction_surveys_improvements_path"
        expect(back_url).to be_nil
        expect(flow.all_steps).to eq request_for_help_form_flow
      end
    end
  end

