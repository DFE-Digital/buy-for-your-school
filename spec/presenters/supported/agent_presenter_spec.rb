require "rails_helper"

RSpec.describe Support::AgentPresenter do
  describe "#full_name" do
    it "returns correctly formatted full name" do
      agent = OpenStruct.new
      # agent = create(:agent)

      presenter = described_class.new(agent)
      expect(presenter.full_name).to eq('Example ProcOps Agent')
    end
  end
end
