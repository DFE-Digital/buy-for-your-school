RSpec.describe Support::Document, type: :model do
  subject(:document) { create(:support_document) }

  it { is_expected.to belong_to :case }
end
