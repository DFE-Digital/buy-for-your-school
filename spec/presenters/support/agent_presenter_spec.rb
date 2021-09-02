RSpec.describe Support::AgentPresenter do
  subject(:presenter) { described_class.new(double) }

  describe "#full_name" do
    it "returns correctly formatted full name" do
      expect(presenter.full_name).to eq("Example ProcOps Agent")
    end
  end
end
