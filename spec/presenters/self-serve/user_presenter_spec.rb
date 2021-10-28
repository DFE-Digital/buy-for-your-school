RSpec.describe UserPresenter do
  subject(:presenter) { described_class.new(user) }

  describe "#full_name" do
    context "when a full name exists" do
      let(:user) { build(:user, full_name: "Ms Phoebe Buffay", first_name: "Phoebe", last_name: "Buffay") }

      it "returns the full name" do
        expect(presenter.full_name).to eq "Ms Phoebe Buffay"
      end
    end

    context "when a full name does not exist" do
      let(:user) { build(:user, full_name: nil, first_name: "Phoebe", last_name: "Buffay") }

      it "concatenates the first and last names" do
        expect(presenter.full_name).to eq "Phoebe Buffay"
      end
    end
  end

  describe "#active_journeys" do
    let(:user) { build(:user, journeys: [build(:journey), build(:journey)]) }

    it "decorates the journeys" do
      expect(presenter.active_journeys).to be_kind_of(Array)
      expect(presenter.active_journeys.all? { |j| j.instance_of?(JourneyPresenter) }).to be true
    end
  end

  describe "#supported_schools" do
    before do
      stub_const("ORG_TYPE_IDS", [1, 2, 3])
    end

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

        results = described_class.new(user).supported_schools

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

        results = described_class.new(user).supported_schools

        expect(results.map(&:name)).to match_array([
          "Supported School 1",
          "Supported School 2",
        ])
      end
    end
  end
end
