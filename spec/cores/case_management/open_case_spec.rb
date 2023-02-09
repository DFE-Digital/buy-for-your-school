require "rails_helper"

describe CaseManagement::OpenCase do
  def open_case! = described_class.new.call(support_case_id: support_case.id, agent_id: support_agent.id, reason: :good_reason)

  let(:support_agent) { create(:support_agent) }

  context "when the case cannot move to open" do
    let(:support_case) { create(:support_case, :closed) }

    it "does not change the state" do
      expect { open_case! }.not_to change { support_case.reload.state }.from("closed")
    end
  end

  context "when the case can move to open" do
    let(:support_case) { create(:support_case, :initial) }

    it "moves the case to opened" do
      expect { open_case! }.to change { support_case.reload.state }.from("initial").to("opened")
    end

    it "broadcasts the case_opened event" do
      with_event_handler(listening_to: :case_opened) do |handler|
        open_case!
        expect(handler).to have_received(:case_opened).with({ support_case_id: support_case.id, previous_state: "initial", reason: :good_reason, agent_id: support_agent.id })
      end
    end
  end
end
