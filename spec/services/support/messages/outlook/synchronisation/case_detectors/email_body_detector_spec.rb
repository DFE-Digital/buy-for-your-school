require "rails_helper"

describe Support::Messages::Outlook::Synchronisation::CaseDetectors::EmailBodyDetector do
  context "when message body contains the case reference in the proper format" do
    let(:message) { double("message-with-ref", body: double(content: "Hello X, Your reference number is: 000999. Bye")) }

    it "returns the reference from the email body" do
      expect(described_class.detect(message)).to eq("000999")
    end
  end

  context "when the message body does not contain the reference in the proper format" do
    let(:message) { double("message-with-ref", body: double(content: "Hello X, 000999. Bye")) }

    it "will not return the reference" do
      expect(described_class.detect(message)).to be_nil
    end
  end
end
