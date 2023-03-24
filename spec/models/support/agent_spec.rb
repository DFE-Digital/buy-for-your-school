RSpec.describe Support::Agent, type: :model do
  it { is_expected.to have_many :cases }

  describe "attributes" do
    subject(:agent) do
      create(:support_agent,
             dsi_uid: "unique id",
             email: "test@test",
             first_name: "John",
             last_name: "Lennon")
    end

    it { is_expected.to be_persisted }

    it "requires a DfE Sign In unique id" do
      expect { create(:support_agent, dsi_uid: nil) }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "requires an email" do
      expect { create(:support_agent, email: nil) }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "requires a first_name and last_name" do
      expect { create(:support_agent, first_name: nil) }.to raise_error(ActiveRecord::NotNullViolation)
      expect { create(:support_agent, last_name: nil) }.to raise_error(ActiveRecord::NotNullViolation)
    end
  end

  describe ".omnisearch" do
    before do
      create(:support_agent, first_name: "Monica", last_name: "Geller")
      create(:support_agent, first_name: "Steve", last_name: "Gelon")
    end

    it "returns agents when searching by first name" do
      agents = described_class.omnisearch("mon")

      expect(agents.size).to eq 1
      expect(agents[0].first_name).to eq "Monica"
    end

    it "returns agents when searching by last name" do
      agents = described_class.omnisearch("gel")

      expect(agents.size).to eq 2
      expect(agents[0].last_name).to eq "Geller"
      expect(agents[1].last_name).to eq "Gelon"
    end
  end

  describe "#initials" do
    subject(:agent) { create(:support_agent, first_name: "Sidney", last_name: "Prescott") }

    it "returns the agent's initials" do
      expect(agent.initials).to eq("SP")
    end
  end
end
