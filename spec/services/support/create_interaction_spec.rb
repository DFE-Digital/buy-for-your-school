RSpec.describe Support::CreateInteraction do
  subject(:service) do
    described_class
  end

  let(:support_case) { create(:support_case) }
  let(:support_agent) { create(:support_agent) }

  context "without a additional data" do
    let(:int_params) do
      {
        case_id: support_case.id,
        event_type: "hub_notes",
        agent_id: support_agent.id,
        body: "some example notes",
      }
    end

    it "creates a new interaction" do
      expect(Support::Interaction.count).to be 0

      result = service.new(
        int_params[:case_id],
        int_params[:event_type],
        int_params[:agent_id],
        { body: int_params[:body] },
      ).call

      expect(Support::Interaction.count).to be 1

      expect(result.case).to eq support_case
      expect(result.agent).to eq support_agent
    end
  end

  context "without additional data" do
    let(:int_params) do
      {
        case_id: support_case.id,
        event_type: "hub_notes",
        agent_id: support_agent.id,
        body: "some example notes",
        additional_data: { example_key: "example data" },
      }
    end

    it "creates a new interaction" do
      expect(Support::Interaction.count).to be 0

      result = service.new(
        int_params[:case_id],
        int_params[:event_type],
        int_params[:agent_id],
        { body: int_params[:body], additional_data: int_params[:additional_data] },
      ).call

      expect(Support::Interaction.count).to be 1

      expect(result.case).to eq support_case
      expect(result.agent).to eq support_agent
      expect(result.additional_data["example_key"]).to eq "example data"
    end
  end
end
