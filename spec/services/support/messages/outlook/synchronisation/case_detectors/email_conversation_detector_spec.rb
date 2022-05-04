require "rails_helper"

describe Support::Messages::Outlook::Synchronisation::CaseDetectors::EmailConversationDetector do
  let(:message) { double("message-with-ref", conversation_id: "987") }

  context "when an email in the conversation chain has already been synchronised" do
    let(:support_case) { create(:support_case, ref: "000123") }

    before { create(:support_email, outlook_conversation_id: "987", case: support_case) }

    context "and that email is attached case 000123" do
      it "returns reference 000123" do
        expect(described_class.detect(message)).to eq("000123")
      end
    end
  end

  context "when no emails exist in the conversation already" do
    it "cannot return a case reference" do
      expect(described_class.detect(message)).to be_nil
    end
  end
end
