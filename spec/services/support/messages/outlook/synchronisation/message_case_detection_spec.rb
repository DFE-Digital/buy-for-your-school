require "rails_helper"

describe Support::Messages::Outlook::Synchronisation::MessageCaseDetection do
  describe "#new_case" do
    let(:message) { double('message', sender: { name: "Test Sender", address: "test@sender.com" }) }

    it "creates a new case based on the message" do
      create_case = double("create_case", call: true)

      allow(Support::CreateCase).to receive(:new).with(
        source:     :incoming_email,
        email:      "test@sender.com",
        first_name: "Test",
        last_name:  "Sender"
      ).and_return(create_case)

      described_class.new(message).new_case

      expect(create_case).to have_received(:call)
    end
  end
end
