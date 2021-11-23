RSpec.describe Support::ActivityLogItem, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:support_case_id) }
    it { is_expected.to validate_presence_of(:action) }
  end
end
