RSpec.describe Support::ActivityLogItem, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:support_case_id) }
    it { is_expected.to validate_presence_of(:action) }
  end

  describe "#to_csv" do
    it "includes headers" do
      expect(described_class.to_csv).to eql(
        "id,support_case_id,action,data,created_at,updated_at\n",
      )
    end
  end
end
