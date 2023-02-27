require "rails_helper"

describe CaseHistory::HandleMessages do
  subject(:handler) { described_class.new }

  let(:support_case_id) { create(:support_case).id }
  let(:support_email_id) { create(:support_email).id }

  describe "#received_email_attached_to_case" do
    it "creates an interaction for the incoming email" do
      payload = { support_case_id:, support_email_id: }
      expect { handler.received_email_attached_to_case(payload) }.to change(Support::Interaction, :count).from(0).to(1)
      interaction = Support::Interaction.last
      expect(interaction.body).to eq("Received email from school")
      expect(interaction.event_type).to eq("email_from_school")
      expect(interaction.case_id).to eq(support_case_id)
      expect(interaction.additional_data["email_id"]).to eq(support_email_id)
    end
  end

  describe "#sent_email_attached_to_case" do
    it "creates an interaction for the incoming email" do
      payload = { support_case_id:, support_email_id: }
      expect { handler.sent_email_attached_to_case(payload) }.to change(Support::Interaction, :count).from(0).to(1)
      interaction = Support::Interaction.last
      expect(interaction.body).to eq("Sent email to school")
      expect(interaction.event_type).to eq("email_to_school")
      expect(interaction.case_id).to eq(support_case_id)
      expect(interaction.additional_data["email_id"]).to eq(support_email_id)
    end
  end
end
