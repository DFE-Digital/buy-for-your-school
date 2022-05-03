require "rails_helper"

describe Support::Messages::Outlook::Synchronisation::CaseDetectors::EmailSubjectLineDetector do

  def message_with_subject(subject)
    double("message-with-ref", subject: subject)
  end

  context "when message subject contains the 6 digit case reference" do
    let(:message) { message_with_subject("000987 This is your email") }

    it "returns the reference from the email subject" do
      expect(described_class.detect(message)).to eq("000987")
    end

    it { expect(described_class.detect(message_with_subject("RE: 999999 This is your email"))).to eq("999999") }
    it { expect(described_class.detect(message_with_subject("FW: RE: Check this out 789678"))).to eq("789678") }
  end

  context "when the message does not contain a 6 digit case reference" do
    let(:message) { message_with_subject("Feedback") }

    it "will not return the reference" do
      expect(described_class.detect(message)).to be_nil
    end
  end
end
