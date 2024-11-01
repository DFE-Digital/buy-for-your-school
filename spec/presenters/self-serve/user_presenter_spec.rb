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
      expect(presenter.active_journeys).to be_a(Array)
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

        expect(results.map(&:name))
          .to contain_exactly("Supported School 1", "Supported School 2")
      end
    end
  end

  describe "#supported_groups" do
    before do
      stub_const("GROUP_CATEGORY_IDS", [1, 2, 3])
    end

    context "when user has a group that is not in the supported group categories" do
      it "is not returned in the results" do
        organisations = [
          {
            "name" => "Unsupported Group",
            "category" => { "id" => "999" },
            "uid" => "1",
          },
          {
            "name" => "Supported Group",
            "category" => { "id" => "2" },
            "uid" => "2",
          },
        ]

        user = instance_double("User", orgs: organisations)

        results = described_class.new(user).supported_groups

        expect(results.map(&:name)).not_to include("Unsupported Group")
      end
    end

    context "when a user has groups that are in the supported group categories" do
      it "returns them in the results" do
        organisations = [
          {
            "name" => "Supported Group 1",
            "category" => { "id" => "1" },
            "uid" => "1",
          },
          {
            "name" => "Supported Group 2",
            "category" => { "id" => "2" },
            "uid" => "2",
          },
          {
            "name" => "Group 3",
            "category" => { "id" => "4" },
            "uid" => "3",
          },
        ]

        user = instance_double("User", orgs: organisations)

        results = described_class.new(user).supported_groups

        expect(results.map(&:name))
          .to contain_exactly("Supported Group 1", "Supported Group 2")
      end
    end
  end

  describe "#supported_orgs" do
    before do
      stub_const("ORG_TYPE_IDS", [1, 2, 3])
      stub_const("GROUP_CATEGORY_IDS", [1, 2, 3])
    end

    it "returns all supported schools and groups sorted by name" do
      organisations = [
        {
          "name" => "A-Supported Group 1",
          "category" => { "id" => "1" },
          "uid" => "1",
        },
        {
          "name" => "C-Supported Group 2",
          "category" => { "id" => "2" },
          "uid" => "2",
        },
        {
          "name" => "D-Supported School 1",
          "type" => { "id" => "1" },
          "urn" => "1",
        },
        {
          "name" => "B-Supported School 2",
          "type" => { "id" => "2" },
          "urn" => "2",
        },
      ]

      user = instance_double("User", orgs: organisations)

      results = described_class.new(user).supported_orgs

      expect(results.map(&:name)).to contain_exactly(
        "A-Supported Group 1",
        "B-Supported School 2",
        "C-Supported Group 2",
        "D-Supported School 1",
      )
    end
  end

  describe "#school_urn" do
    before do
      stub_const("ORG_TYPE_IDS", [1])
      stub_const("GROUP_CATEGORY_IDS", [1])
    end

    context "when user has one org and it's a school" do
      it "returns the school URN" do
        organisations = [
          {
            "name" => "Supported School 1",
            "type" => { "id" => "1" },
            "urn" => "1",
          },
        ]

        user = instance_double("User", orgs: organisations)

        results = described_class.new(user).school_urn

        expect(results).to eq "1"
      end
    end

    context "when user has one org and it's a group" do
      it "returns nil" do
        organisations = [
          {
            "name" => "Supported Group 1",
            "category" => { "id" => "1" },
            "uid" => "1",
          },
        ]

        user = instance_double("User", orgs: organisations)

        results = described_class.new(user).school_urn

        expect(results).to be_nil
      end
    end

    context "when user has multiple orgs" do
      it "returns nil" do
        organisations = [
          {
            "name" => "Supported School 1",
            "type" => { "id" => "1" },
            "urn" => "1",
          },
          {
            "name" => "Supported Group 1",
            "category" => { "id" => "1" },
            "uid" => "1",
          },
        ]

        user = instance_double("User", orgs: organisations)

        results = described_class.new(user).school_urn

        expect(results).to be_nil
      end
    end
  end

  describe "#group_uid" do
    before do
      stub_const("ORG_TYPE_IDS", [1])
      stub_const("GROUP_CATEGORY_IDS", [1])
    end

    context "when user has one org and it's a group" do
      it "returns the group UID" do
        organisations = [
          {
            "name" => "Supported Group 1",
            "category" => { "id" => "1" },
            "uid" => "1",
          },
        ]

        user = instance_double("User", orgs: organisations)

        results = described_class.new(user).group_uid

        expect(results).to eq "1"
      end
    end

    context "when user has one org and it's a school" do
      it "returns nil" do
        organisations = [
          {
            "name" => "Supported School 1",
            "category" => { "id" => "1" },
            "urn" => "1",
          },
        ]

        user = instance_double("User", orgs: organisations)

        results = described_class.new(user).group_uid

        expect(results).to be_nil
      end
    end

    context "when user has multiple orgs" do
      it "returns nil" do
        organisations = [
          {
            "name" => "Supported School 1",
            "type" => { "id" => "1" },
            "urn" => "1",
          },
          {
            "name" => "Supported Group 1",
            "category" => { "id" => "1" },
            "uid" => "1",
          },
        ]

        user = instance_double("User", orgs: organisations)

        results = described_class.new(user).group_uid

        expect(results).to be_nil
      end
    end
  end

  describe "#single_org?" do
    before do
      stub_const("ORG_TYPE_IDS", [1])
      stub_const("GROUP_CATEGORY_IDS", [1])
    end

    context "when user has only one supported org" do
      it "return true" do
        organisations = [
          {
            "name" => "Supported School 1",
            "type" => { "id" => "1" },
            "urn" => "1",
          },
        ]

        user = instance_double("User", orgs: organisations)

        results = described_class.new(user).single_org?

        expect(results).to eq true
      end
    end

    context "when user has more than one supported org" do
      it "return false" do
        organisations = [
          {
            "name" => "Supported School 1",
            "type" => { "id" => "1" },
            "urn" => "1",
          },
          {
            "name" => "Supported Group 1",
            "category" => { "id" => "1" },
            "uid" => "1",
          },
        ]

        user = instance_double("User", orgs: organisations)

        results = described_class.new(user).single_org?

        expect(results).to eq false
      end
    end
  end
end
