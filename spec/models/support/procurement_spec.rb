RSpec.describe Support::Procurement, type: :model do
  it { is_expected.to have_many(:cases).dependent(:nullify) }
end
