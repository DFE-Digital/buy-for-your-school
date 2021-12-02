require "rails_helper"

RSpec.describe NewContract, type: :model do
  it { is_expected.to have_one(:support_case) }
end
