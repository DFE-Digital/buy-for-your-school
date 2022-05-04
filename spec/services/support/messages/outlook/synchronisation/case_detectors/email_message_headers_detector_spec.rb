require "rails_helper"

describe Support::Messages::Outlook::Synchronisation::CaseDetectors::EmailMessageHeadersDetector do
  def message_with_headers(headers)
    double("message-with-headers", internet_message_headers: headers.map { |k, v| { name: k, value: v } })
  end

  context "when the GHBSCaseReference header exists" do
    let(:message) { message_with_headers({ "GHBSCaseReference" => "000321" }) }

    it "returns the reference from the email header" do
      expect(described_class.detect(message)).to eq("000321")
    end
  end

  context "when the GHBSCaseReference header is missing" do
    let(:message) { message_with_headers({}) }

    it "will not return the reference" do
      expect(described_class.detect(message)).to be_nil
    end
  end
end
