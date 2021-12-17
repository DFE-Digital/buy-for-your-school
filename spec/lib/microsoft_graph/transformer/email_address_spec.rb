require "spec_helper"

describe MicrosoftGraph::Transformer::EmailAddress do
  describe "transformation into its resource" do
    it "maps response json field names to object fields" do
      payload = {
        "address" => "email@address.com",
        "name" => "Email@address.com",
      }

      email_address = described_class.transform(payload, into: MicrosoftGraph::Resource::EmailAddress)

      expect(email_address.address).to eq("email@address.com")
      expect(email_address.name).to eq("Email@address.com")
    end
  end
end
