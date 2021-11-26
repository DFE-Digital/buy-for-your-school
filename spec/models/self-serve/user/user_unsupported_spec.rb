RSpec.describe User, type: :model do
  around do |example|
    ClimateControl.modify(PROC_OPS_TEAM: "DfE Commercial Procurement Operations") { example.run }
  end

  describe "unsupported" do
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

    context "when single org" do
      it "only returns unsupported users" do
        expect(described_class.unsupported.count).to eq 1
        expect(described_class.unsupported[0].first_name).to eq "test_unsupported"
      end
    end

    context "when multiple orgs" do
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

      it "only returns unsupported users" do
        expect(described_class.unsupported.count).to eq 1
        expect(described_class.unsupported[0].first_name).to eq "test_unsupported"
      end
    end

    context "when org without type" do
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

    let(:unsupported_user_without_type) do
      create(:user,
             first_name: "test_unsupported_without_type",
             orgs: [{
               "id": "23F20E54-79EA-4146-8E39-18197576F023",
               "name": "Unsupported School Name",
             }])
    end

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

    let(:supported_user_without_type) do
      create(:user,
             first_name: "test_supported_without_type",
             orgs: [{
               "id": "23F20E54-79EA-4146-8E39-18197576F023",
               "name": "DfE Commercial Procurement Operations",
             }])
    end

    it "returns true" do
      expect(unsupported_user_with_type.unsupported?).to be true
      expect(unsupported_user_without_type.unsupported?).to be true
    end

    it "returns false" do
      expect(supported_user_with_type.unsupported?).to be false
      expect(supported_user_without_type.unsupported?).to be false
    end
  end
end
