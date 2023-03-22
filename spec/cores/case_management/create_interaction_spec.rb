require "rails_helper"

describe CaseManagement::CreateInteraction do
  def create_interaction! = instance.call(support_case_id: support_case.id, agent_id: support_agent.id, event_type: :phone_call, body: "ring")

  let(:instance) { described_class.new }
  let(:support_case) { create(:support_case) }
  let(:support_agent) { create(:support_agent) }

  context "when the interaction is saved successfully" do
    it "persists the interaction" do
      allow(instance).to receive(:broadcast)

      expect { create_interaction! }.to change(Support::Interaction, :count).from(0).to(1)
      interaction = Support::Interaction.last
      expect(interaction.case_id).to eq(support_case.id)
      expect(interaction.agent_id).to eq(support_agent.id)
      expect(interaction.event_type).to eq("phone_call")
      expect(interaction.body).to eq("ring")
    end

    it "broadcasts the interaction_created event" do
      with_event_handler(listening_to: :interaction_created) do |handler|
        create_interaction!
        interaction = Support::Interaction.last
        expect(handler).to have_received(:interaction_created).with({ interaction_id: interaction.id, support_case_id: interaction.case.id, event_type: interaction.event_type.to_sym })
      end
    end
  end
end
