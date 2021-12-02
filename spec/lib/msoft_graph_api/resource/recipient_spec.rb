require "spec_helper"

describe MsoftGraphApi::Resource::Recipient do
  describe ".from_payload" do
    it "maps response json field names to object fields" do
      payload = {
        "emailAddress" => { "address" => "x", "name" => "y" },
      }

      recipient = described_class.from_payload(payload)

      expect(recipient.email_address.as_json).to match(MsoftGraphApi::Resource::EmailAddress.from_payload(payload["emailAddress"]).as_json)
    end
  end
end
