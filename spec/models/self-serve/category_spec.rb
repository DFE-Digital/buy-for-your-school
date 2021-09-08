RSpec.describe Category, type: :model do
  it { is_expected.to have_many(:journeys) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:contentful_id) }
    it { is_expected.to validate_presence_of(:liquid_template) }
  end
end
