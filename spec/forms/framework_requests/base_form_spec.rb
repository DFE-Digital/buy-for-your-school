describe FrameworkRequests::BaseForm, type: :model do
  subject(:form) { described_class.new(**data) }

  let(:data) { {} }

  it { is_expected.to delegate_method(:allow_bill_upload?).to(:framework_request) }

  describe "#dsi?" do
    let(:data) { { dsi: "true" } }

    it "returns the value as a boolean" do
      expect(form.dsi?).to eq true
    end
  end

  describe "#group?" do
    let(:data) { { school_type: "group" } }

    it "returns true if the school type is 'group'" do
      expect(form.group?).to eq true
    end
  end

  describe "#org_confirm?" do
    let(:data) { { org_confirm: "true" } }

    it "returns the value as a boolean" do
      expect(form.org_confirm?).to eq true
    end
  end

  describe "#to_h" do
    let(:data) { { id: "id", school_type: "school", dsi: "true", user: nil } }

    it "returns the instance variables and their values" do
      expect(form.to_h).to eq data
    end
  end

  describe "#data" do
    let(:data) { { id: "id", school_type: "school", dsi: "true", org_confirm: "false", special_requirements_choice: "true" } }

    it "returns the instance variables relevant for persisting" do
      expect(form.data).to eq({})
    end
  end

  describe "#common" do
    let(:data) { { id: "id", school_type: "school", dsi: "true", org_confirm: "false", special_requirements_choice: "true", user: } }

    context "when we have a DSI user" do
      let(:user) { build(:user) }

      it "returns an empty hash" do
        expect(form.common).to eq({})
      end
    end

    context "when we do not have a DSI user" do
      let(:user) { build(:guest) }

      it "returns the instance variables common to all sub-forms" do
        expect(form.common).to eq({ school_type: "school", dsi: "true", org_confirm: "false", special_requirements_choice: "true" })
      end
    end
  end

  describe "#framework_request" do
    let(:framework_request) { create(:framework_request) }
    let(:data) { { id: framework_request.id } }

    it "returns the framework request" do
      expect(form.framework_request).to eq framework_request
    end
  end
end
