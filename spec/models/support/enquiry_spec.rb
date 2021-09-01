RSpec.describe Support::Enquiry, type: :model do
  it { is_expected.to have_many(:documents) }
  it { is_expected.to belong_to(:case).optional }
end
