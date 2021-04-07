require "rails_helper"

RSpec.describe Section, type: :model do
  it { should belong_to(:journey) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:contentful_id) }
  end
end
