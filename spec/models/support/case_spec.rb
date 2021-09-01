RSpec.describe Support::Case, type: :model do
  it { is_expected.to belong_to(:category) }
  it { is_expected.to have_one(:enquiry) }
  it { is_expected.to have_many(:documents) }

  it { is_expected.to define_enum_for(:support_level).with(%i[L1 L2 L3 L4 L5]) }
  it { is_expected.to define_enum_for(:state).with(%i[initial open resolved pending closed pipeline no_response]) }
end
