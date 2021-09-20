RSpec.describe Support::UpdateCase do
  subject(:service) { described_class.new(current_case, agent) }

  let(:current_case) { create(:support_case, state: state) }
  let(:agent)  { create(:support_agent) }
  let(:result) { service.call }

  describe "#call" do
    context "when a new case is given" do
      let(:state) { "initial" }

      it "opens the case" do
        expect(result.state).to eq("open")
      end

      it "assigns the case to the appointed agent" do
        expect(result.agent).to eq(agent)
      end

      it "returns the original case" do
        expect(result).to eq(current_case)
      end
    end

    context "when an already open case is given" do
      let(:state) { "open" }

      it "keeps the case open" do
        expect(result.state).to eq("open")
      end

      it "assigns the case to the appointed agent" do
        expect(result.agent).to eq(agent)
      end

      it "returns the original case" do
        expect(result).to eq(current_case)
      end
    end
  end
end
