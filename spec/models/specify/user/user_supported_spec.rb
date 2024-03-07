RSpec.describe User, type: :model do
  describe ".supported" do
    before do
      create(:user,
             first_name: "test_supported",
             orgs: [{
               "id": "23F20E54-79EA-4146-8E39-18197576F023",
               "name": "Supported School Name",
               "type": {
                 "id": "1",
               },
             }])

      create(:user,
             first_name: "test_unsupported",
             orgs: [{
               "id": "23F20E54-79EA-4146-8E39-18197576F023",
               "name": "Unsupported School Name",
               "type": {
                 "id": "4",
               },
             }])
    end

    context "when there are supported and unsupported users" do
      it "only returns supported users" do
        expect(described_class.supported.count).to eq 1
        expect(described_class.supported[0].first_name).to eq "test_supported"
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

      it "returns the user" do
        expect(described_class.supported.count).to eq 2
        expect(described_class.supported[0].first_name).to eq "test_supported"
        expect(described_class.supported[1].first_name).to eq "test_mixed"
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

      it "ignores the user" do
        expect(described_class.supported.count).to eq 1
        expect(described_class.supported[0].first_name).to eq "test_supported"
      end
    end
  end
end
