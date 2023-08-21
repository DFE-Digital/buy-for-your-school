RSpec.describe FrameworkRequest, type: :model do
  subject(:framework_request) { build(:framework_request, group:, org_id:, is_energy_request:, energy_request_about:, have_energy_bill:, energy_alternative:, school_urns:) }

  let(:is_energy_request) { false }
  let(:energy_request_about) { nil }
  let(:have_energy_bill) { false }
  let(:energy_alternative) { nil }
  let(:school_urns) { [] }
  let(:group) { false }
  let(:org_id) { nil }

  it { is_expected.to belong_to(:user).optional }
  it { is_expected.to belong_to(:category).class_name("RequestForHelpCategory").optional }

  describe "#allow_bill_upload?" do
    context "when feature :energy_bill_flow is not enabled" do
      before { Flipper.disable(:energy_bill_flow) }

      it "returns false" do
        framework_request = described_class.new
        expect(framework_request.allow_bill_upload?).to be(false)
      end
    end

    context "when it's an energy request about a contract and they have a bill to upload" do
      let(:is_energy_request) { true }
      let(:energy_request_about) { :energy_contract }
      let(:have_energy_bill) { true }

      it "returns true" do
        expect(framework_request.allow_bill_upload?).to eq true
      end
    end

    context "when it's an energy request about a contract and they have a bill in a different format" do
      let(:is_energy_request) { true }
      let(:energy_request_about) { :energy_contract }
      let(:have_energy_bill) { false }
      let(:energy_alternative) { :different_format }

      it "returns true" do
        expect(framework_request.allow_bill_upload?).to eq true
      end
    end

    context "when it's not an energy request" do
      let(:is_energy_request) { false }

      it "returns false" do
        expect(framework_request.allow_bill_upload?).to eq false
      end
    end

    context "when it's an energy request not about a contract" do
      let(:is_energy_request) { true }
      let(:energy_request_about) { :not_energy_contract }

      it "returns false" do
        expect(framework_request.allow_bill_upload?).to eq false
      end
    end

    context "when it's an energy request about a contract but they don't have a bill in a different format" do
      let(:is_energy_request) { true }
      let(:energy_request_about) { :energy_contract }
      let(:have_energy_bill) { false }
      let(:energy_alternative) { :no_bill }

      it "returns false" do
        expect(framework_request.allow_bill_upload?).to eq false
      end
    end
  end

  describe "#has_bills?" do
    context "when there are associated energy bills" do
      before { create(:energy_bill, framework_request:) }

      it "returns true" do
        expect(framework_request.has_bills?).to eq true
      end
    end

    context "when there are no associated energy bills" do
      it "returns false" do
        expect(framework_request.has_bills?).to eq false
      end
    end
  end

  describe "#selected_schools" do
    before do
      create(:support_organisation, urn: "1", name: "School 1")
      create(:support_organisation, urn: "2", name: "School 2")
      create(:support_organisation, urn: "3", name: "School 3")
    end

    let(:school_urns) { %w[1 2 3] }

    it "returns all selected schools" do
      expect(framework_request.selected_schools.pluck(:name)).to match_array(["School 1", "School 2", "School 3"])
    end
  end

  describe "when the user has selected a SAT" do
    let(:group) { true }
    let(:org_id) { "123" }

    before do
      establishment_group_type = create(:support_establishment_group_type, name: "Single-academy Trust", code: 10)
      create(:support_establishment_group, name: "Single academy trust 1", uid: "123", establishment_group_type:)
      create(:support_organisation, name: "SAT school", urn: "456", trust_code: "123")
    end

    it "automatically persists the school associated with the SAT" do
      framework_request.save!

      expect(framework_request.school_urns).to match_array(%w[456])
    end
  end
end
