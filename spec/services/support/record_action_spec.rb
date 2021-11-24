RSpec.describe Support::RecordAction do
  subject(:service) { described_class.new(action: action, case_id: support_case.id, data: data) }

  let(:support_case) { create(:support_case) }
  let(:data) { {} }

  describe "#call" do
    let(:action) { "open_case" }

    it "records the action in the database" do
      expect(service.call.action).to eq "open_case"
    end

    context "when the action has additional parameters specified" do
      let(:action) { "add_interaction" }
      let(:data) { { event_type: "phone" } }

      it "correctly records additional parameters" do
        expect(service.call.support_case_id).to eq support_case.id
        expect(service.call.data).to eq({ "event_type" => "phone" })
      end
    end

    context "when the new action has an unexpected action type" do
      let(:action) { "invalid_action" }

      it "raises an error" do
        expect { service }.to raise_error Dry::Types::ConstraintError
      end
    end
  end
end
