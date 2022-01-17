require "rails_helper"

RSpec.describe Support::ExistingContract, type: :model do
  it { is_expected.to have_one(:support_case) }
end
