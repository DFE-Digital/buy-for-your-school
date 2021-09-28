RSpec.describe Support::EnquiryPresenter do
  subject(:presenter) { described_class.new(enquiry) }

  let(:enquiry) { create(:support_enquiry) }

  describe "#category" do
    it "returns a decorated category" do
      expect(presenter.category).to be_a(Support::CategoryPresenter)
    end
  end
end
