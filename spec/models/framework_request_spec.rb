require "rails_helper"

describe FrameworkRequest do
  describe "#allow_bill_upload?" do
    context "when feature :energy_bill_flow is not enabled" do
      before { Flipper.disable(:energy_bill_flow) }

      it "returns false" do
        framework_request = described_class.new
        expect(framework_request.allow_bill_upload?).to be(false)
      end
    end
  end
end
