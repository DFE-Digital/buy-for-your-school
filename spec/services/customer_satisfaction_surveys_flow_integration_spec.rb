RSpec.describe CustomerSatisfactionSurveysFlow do
  let(:expected_flows) do
    {
      "find_a_framework" => %w[recommendation_likelihood improvement easy_to_use_rating helped_how clear_to_use_rating research_opt_in satisfaction_level thank_you],
      "create_a_spec" => %w[recommendation_likelihood improvement easy_to_use_rating helped_how clear_to_use_rating research_opt_in satisfaction_level thank_you],
      "supported_journey" => %w[recommendation_likelihood improvement easy_to_use_rating helped_how clear_to_use_rating research_opt_in satisfaction_level thank_you],
      "request_for_help_form" => %w[recommendation_likelihood improvement easy_to_use_rating helped_how clear_to_use_rating research_opt_in satisfaction_level thank_you],
      "energy_for_schools" => %w[recommendation_likelihood improvement easy_to_use_rating helped_how clear_to_use_rating research_opt_in satisfaction_level thank_you],
      "find_a_buying_solution" => %w[satisfaction_level easy_to_use_rating helped_how clear_to_use_rating recommendation_likelihood improvement thank_you],
    }
  end

  it "validates the correct flow for each service" do
    expected_flows.each do |service, expected_flow|
      # Creating a survey for each service and then retrieving the flow
      survey = CustomerSatisfactionSurveyResponse.create!(
        service:,
        status: "completed",
      )

      actual_flow = described_class.new(survey.service).all_steps
      expect(actual_flow).to eq(expected_flow)
    end
  end
end
