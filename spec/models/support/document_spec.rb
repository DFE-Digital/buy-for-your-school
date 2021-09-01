RSpec.describe Support::Document, type: :model do
  it { is_expected.to belong_to(:documentable).optional }
end
