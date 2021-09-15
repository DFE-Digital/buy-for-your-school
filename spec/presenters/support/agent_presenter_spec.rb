RSpec.describe Support::AgentPresenter do
  subject(:presenter) { described_class.new(agent) }

  let(:agent) { OpenStruct.new(first_name: "foo", last_name: "bar") }

  describe "#full_name" do
    it "returns the correctly formatted full name" do
      expect(presenter.full_name).to eq("Foo Bar")
    end
  end
end
