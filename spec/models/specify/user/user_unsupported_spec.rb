RSpec.describe User, type: :model do
  around do |example|
    described_class.destroy_all
    ClimateControl.modify(PROC_OPS_TEAM: "DfE Commercial Procurement Operations") { example.run }
  end

  describe ".unsupported" do
    before do
      create(:user,
             first_name: "test_unsupported",
             orgs: [{
               "id": "23F20E54-79EA-4146-8E39-18197576F023",
               "name": "Unsupported School Name",
               "type": {
                 "id": "4",
               },
             }])

      create(:user,
             first_name: "test_supported",
             orgs: [{
               "id": "23F20E54-79EA-4146-8E39-18197576F023",
               "name": "Supported School Name",
               "type": {
                 "id": "1",
               },
             }])
    end

    context "when user belongs to unsupported org" do
      it "returns the user" do
        expect(described_class.unsupported.count).to eq 1
        expect(described_class.unsupported[0].first_name).to eq "test_unsupported"
      end
    end

    context "when user belongs to unsupported and supported org" do
      before do
        create(:user,
               first_name: "test_mixed",
               orgs: [
                 {
                   "id": "23F20E54-79EA-4146-8E39-18197576F023",
                   "name": "Supported School Name",
                   "type": {
                     "id": "1",
                   },
                 },
                 {
                   "id": "23F20E54-79EA-4146-8E39-18197576F023",
                   "name": "Unsupported School Name",
                   "type": {
                     "id": "4",
                   },
                 },
               ])
      end

      it "ignores the user" do
        expect(described_class.unsupported.count).to eq 1
        expect(described_class.unsupported[0].first_name).to eq "test_unsupported"
      end
    end

    context "when user belongs to org without type" do
      before do
        create(:user,
               first_name: "test_no_type",
               orgs: [
                 {
                   "id": "23F20E54-79EA-4146-8E39-18197576F023",
                   "name": "School without type",
                 },
               ])
      end

      it "returns the user" do
        expect(described_class.unsupported.count).to eq 2
        expect(described_class.unsupported[0].first_name).to eq "test_unsupported"
        expect(described_class.unsupported[1].first_name).to eq "test_no_type"
      end
    end
  end

  describe "#unsupported?" do
    context "when the org is unsupported" do
      let(:unsupported_user_with_type) do
        create(:user,
               first_name: "test_unsupported_with_type",
               orgs: [{
                 "id": "23F20E54-79EA-4146-8E39-18197576F023",
                 "name": "Unsupported School Name",
                 "type": {
                   "id": "4",
                 },
               }])
      end

      it "returns true" do
        expect(unsupported_user_with_type.unsupported?).to be true
      end
    end

    context "when the org has no type" do
      let(:unsupported_user_without_type) do
        create(:user,
               first_name: "test_unsupported_without_type",
               orgs: [{
                 "id": "23F20E54-79EA-4146-8E39-18197576F023",
                 "name": "Unsupported School Name",
               }])
      end

      it "returns true" do
        expect(unsupported_user_without_type.unsupported?).to be true
      end
    end

    context "when the org is supported" do
      let(:supported_user_with_type) do
        create(:user,
               first_name: "test_supported_with_type",
               orgs: [{
                 "id": "23F20E54-79EA-4146-8E39-18197576F023",
                 "name": "Supported School Name",
                 "type": {
                   "id": "1",
                 },
               }])
      end

      it "returns false" do
        expect(supported_user_with_type.unsupported?).to be false
      end
    end

    context "when the org is internal" do
      let(:supported_user_internal) do
        create(:user,
               first_name: "test_supported_internal",
               orgs: [{
                 "id": "23F20E54-79EA-4146-8E39-18197576F023",
                 "name": "DfE Commercial Procurement Operations",
               }])
      end

      it "returns false" do
        expect(supported_user_internal.unsupported?).to be false
      end
    end
  end
end
