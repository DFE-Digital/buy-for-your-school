RSpec.describe SupportRequest, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:category).optional }
  it { is_expected.to belong_to(:journey).optional }

  describe "validations" do
    it { is_expected.to validate_presence_of(:message) }
  end
end
