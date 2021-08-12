RSpec.describe SupportRequest, type: :model do
  it { is_expected.to belong_to(:user) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:message) }
  end
end
