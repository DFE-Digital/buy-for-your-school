RSpec.describe Support::CasePresenter do
  let(:kase) do
    OpenStruct.new(
      state: "foo",
      interactions: [double],
      case_worker_account: OpenStruct.new(name: "bar"),
      category: double,
      contact: double,
    )
  end

  subject(:presenter) { described_class.new(kase) }

  describe "#state" do
    it "returns an upcase state" do
      expect(presenter.state).to eq("FOO")
    end
  end

  describe "#agent_name" do
    it "returns the name of the agent that's assigned to the case" do
      expect(presenter.agent_name).to eq("bar")
    end
  end

  describe "#interactions" do
    it "returns an array of decorated interactions" do
      expect(presenter.interactions.first).to be_a(Support::InteractionPresenter)
    end
  end

  describe "#contact" do
    it "returns a decorated contact" do
      expect(presenter.contact).to be_a(Support::ContactPresenter)
    end
  end

  describe "#category" do
    it "returns a decorated category" do
      expect(presenter.category).to be_a(Support::CategoryPresenter)
    end
  end
end
