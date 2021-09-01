require "rails_helper"

RSpec.describe Support::AgentPresenter do
  let(:presenter) { described_class.new(double) }

  describe "#full_name" do
    it "returns correctly formatted full name" do
      expect(presenter.full_name).to eq('Example ProcOps Agent')
    end
  end
end
