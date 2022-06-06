require "rails_helper"

describe Support::Messages::Outlook::MessageAttachment do
  describe "#filename" do
    it "returns the name from the delegated object" do
      attachment = double("attachment", name: "ATTACHMENT_NAME.txt")
      expect(described_class.new(attachment).filename).to eq("ATTACHMENT_NAME.txt")
    end
  end
end
