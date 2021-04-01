require "rails_helper"

RSpec.describe Section, type: :model do
  it { should belong_to(:journey) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
  end
end
