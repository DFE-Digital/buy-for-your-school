RSpec.describe ActivityLogItem, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:journey_id) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:action) }
  end
end
