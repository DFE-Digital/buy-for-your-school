require "rails_helper"

describe Support::Case::Surveyable do
  describe "on retrieving the caseworker name for the customer satisfaction survey" do
    let(:support_case) { create(:support_case, :resolved, agent:) }

    context "when the case has an assigned caseworker" do
      let(:agent) { create(:support_agent, first_name: "Justin", last_name: "Case") }

      it "gets the current caseworker's name" do
        expect(support_case.agent_for_satisfaction_survey).to eq("Justin Case")
      end
    end

    context "when the case has no assigned caseworker" do
      let(:agent) { nil }

      before do
        another_agent = create(:support_agent, first_name: "Barry", last_name: "Cade")
        another_agent_2 = create(:support_agent, first_name: "Kerry", last_name: "Oki")
        create(:support_interaction, event_type: :note, body: "A note", case: support_case, agent: another_agent_2)
        create(:support_interaction, event_type: :state_change, body: "From initial to open", case: support_case, agent: another_agent_2)
        create(:support_interaction, event_type: :state_change, body: "From open to resolved", case: support_case, agent: another_agent)
        create(:support_interaction, event_type: :phone_call, body: "Ring", case: support_case, agent: another_agent_2)
      end

      it "gets the name of the caseworker who resolved the case" do
        expect(support_case.agent_for_satisfaction_survey).to eq("Barry Cade")
      end
    end

    context "when no caseworker can be resolved" do
      let(:agent) { nil }

      it "gets the name of the service" do
        expect(support_case.agent_for_satisfaction_survey).to eq("Get help buying for schools")
      end
    end
  end
end
