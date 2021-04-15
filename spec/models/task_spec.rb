require "rails_helper"

RSpec.describe Task, type: :model do
  it { should belong_to(:section) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:contentful_id) }
  end
end
