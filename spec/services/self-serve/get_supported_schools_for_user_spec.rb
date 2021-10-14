require "rails_helper"

describe GetSupportedSchoolsForUser do
  before do
    stub_const("ORG_TYPE_IDS", [1, 2, 3])
  end

  describe "#call" do
    context "when user has a school that is not in the supported organisation types" do
      it "is not returned in the results" do
        organisations = [
          {
            "name" => "Unsupported School",
            "type" => { "id" => "999" },
            "urn" => "1",
          },
          {
            "name" => "Supported School",
            "type" => { "id" => "2" },
            "urn" => "2",
          },
        ]

        user = instance_double("User", orgs: organisations)

        results = described_class.new(user: user).call

        expect(results.map(&:name)).not_to include("Unsupported School")
      end
    end

    context "when a user has schools that are in the supported organisation types" do
      it "returns them in the results" do
        organisations = [
          {
            "name" => "Supported School 1",
            "type" => { "id" => "1" },
            "urn" => "1",
          },
          {
            "name" => "Supported School 2",
            "type" => { "id" => "2" },
            "urn" => "2",
          },
          {
            "name" => "School 3",
            "type" => { "id" => "4" },
            "urn" => "3",
          },
        ]

        user = instance_double("User", orgs: organisations)

        results = described_class.new(user: user).call

        expect(results.map(&:name)).to match_array([
          "Supported School 1",
          "Supported School 2",
        ])
      end
    end
  end
end
