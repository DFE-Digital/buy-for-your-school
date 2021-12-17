require "spec_helper"

describe MicrosoftGraph::Transformer::Recipient do
  describe "transformation into its resource" do
    it "maps response json field names to object fields" do
      payload = {
        "emailAddress" => { "address" => "x", "name" => "y" },
      }

      recipient = described_class.transform(payload, into: MicrosoftGraph::Resource::Recipient)

      expect(recipient.email_address.as_json).to match(
        MicrosoftGraph::Transformer::EmailAddress.transform(payload["emailAddress"],
                                                            into: MicrosoftGraph::Resource::EmailAddress).as_json,
      )
    end
  end
end
