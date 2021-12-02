require "spec_helper"

describe MsoftGraphApi::Resource::EmailAddress do
  describe ".from_payload" do
    it "maps response json field names to object fields" do
      payload = {
        "address" => "email@address.com",
        "name" => "Email@address.com",
      }

      email_address = described_class.from_payload(payload)

      expect(email_address.address).to eq("email@address.com")
      expect(email_address.name).to eq("Email@address.com")
    end
  end
end
