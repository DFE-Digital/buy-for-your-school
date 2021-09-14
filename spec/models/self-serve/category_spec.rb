RSpec.describe Category, type: :model do
  it { is_expected.to have_many(:journeys) }

  describe "validations" do
    subject { described_class.new(title: "Category", description: "description", contentful_id: "id", liquid_template: "temp", slug: "slug") }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:contentful_id) }
    it { is_expected.to validate_presence_of(:liquid_template) }
    it { is_expected.to validate_uniqueness_of(:contentful_id) }
  end
end
