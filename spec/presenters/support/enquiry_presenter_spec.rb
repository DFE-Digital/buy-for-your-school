RSpec.describe Support::EnquiryPresenter do
  subject(:presenter) { described_class.new(enquiry) }

  let(:enquiry) { create(:support_enquiry) }

  describe "#category" do
    it "is string" do
      expect(presenter.category).to be_a(String)
    end
  end
end
