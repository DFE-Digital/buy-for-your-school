require "rails_helper"

describe Support::Messages::Outlook::Synchronisation::MessageCaseDetection do
  describe "#new_case" do
    let(:message) { double("message", sender: { name: "Test Sender", address: "test@sender.com" }) }

    it "creates a new case based on the message" do
      create_case = double("create_case", call: true)

      allow(Support::CreateCase).to receive(:new).with(
        source: :incoming_email,
        email: "test@sender.com",
        first_name: "Test",
        last_name: "Sender",
      ).and_return(create_case)

      described_class.new(message).new_case

      expect(create_case).to have_received(:call)
    end
  end

  describe "#detect_existing_or_create_new_case" do
    subject(:case_detection) { described_class.new(message) }

    let!(:existing_case) { create(:support_case, ref: "123456") }
    let(:message) { double("message", body: double(content: ""), subject: "About your case", conversation_id: 0) }

    context "when an existing case can be found from the email body" do
      let(:message) { double("message", body: double(content: "Your reference number is: 123456."), subject: "About your case", conversation_id: 1) }

      it "returns the existing case" do
        expect(case_detection.detect_existing_or_create_new_case).to eq(existing_case)
      end
    end

    context "when an existing case can be found from the email subject line" do
      let(:message) { double("message", body: double(content: ""), subject: "About your case 123456", conversation_id: 2) }

      it "returns the existing case" do
        expect(case_detection.detect_existing_or_create_new_case).to eq(existing_case)
      end
    end

    context "when an existing case can be found from the message conversation" do
      let!(:existing_email) { create(:support_email, case: existing_case, outlook_conversation_id: "OCID1234") }
      let(:message) { double("message", body: double(content: ""), subject: "About your case", conversation_id: "OCID1234") }

      it "returns the existing case" do
        expect(case_detection.detect_existing_or_create_new_case).to eq(existing_case)
      end
    end

    it "returns a new case" do
      new_case = double("new_case")
      allow(case_detection).to receive(:new_case).and_return(new_case)
      expect(case_detection.detect_existing_or_create_new_case).to eq(new_case)
    end
  end
end
