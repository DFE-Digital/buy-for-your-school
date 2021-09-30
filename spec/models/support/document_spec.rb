RSpec.describe Support::Document, type: :model do
  subject { document.documentable }

  let(:documentable) { nil }
  let(:document) { create(:support_document, documentable: documentable) }

  context "when document belongs to a case" do
    let!(:documentable) { create(:support_case) }

    it { is_expected.to be_kind_of documentable.class }
  end

  context "when document belongs to an enquiry" do
    let!(:documentable) { create(:support_enquiry) }

    it { is_expected.to be_kind_of documentable.class }
  end
end
