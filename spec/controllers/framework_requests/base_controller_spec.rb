describe FrameworkRequests::BaseController, type: :controller do
  describe "#last_energy_path" do
    before do
      allow(controller).to receive(:framework_request).and_return(framework_request)
      allow(controller).to receive(:form).and_return(FrameworkRequests::BaseForm.new(user: build(:user)))
    end

    context "when the energy alternative question has been answered" do
      let(:framework_request) { build(:framework_request, energy_alternative: "different_format") }

      it "returns the energy alternative path" do
        expect(controller.send(:last_energy_path)).to eq "/procurement-support/energy_alternative"
      end
    end

    context "when the energy bill question has been answered" do
      let(:framework_request) { build(:framework_request, have_energy_bill: true) }

      it "returns the energy bill path" do
        expect(controller.send(:last_energy_path)).to eq "/procurement-support/energy_bill"
      end
    end

    context "when the energy request about question has been answered" do
      let(:framework_request) { build(:framework_request, energy_request_about: "energy_contract") }

      it "returns the energy request about path" do
        expect(controller.send(:last_energy_path)).to eq "/procurement-support/energy_request_about"
      end
    end

    context "when none of the other energy questions have been answered" do
      let(:framework_request) { build(:framework_request) }

      it "returns the energy request path" do
        expect(controller.send(:last_energy_path)).to eq "/procurement-support/energy_request"
      end
    end
  end
end
