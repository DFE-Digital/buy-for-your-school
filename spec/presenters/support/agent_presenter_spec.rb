RSpec.describe Support::AgentPresenter do
  subject(:presenter) { described_class.new(agent) }

  let(:agent) { OpenStruct.new(first_name: "Donald", last_name: "McDonald") }

  describe "#full_name" do
    it "joins first and last name" do
      expect(presenter.full_name).to eq("Donald McDonald")
    end
  end
end
