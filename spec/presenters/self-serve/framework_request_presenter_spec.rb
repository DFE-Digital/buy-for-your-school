RSpec.describe FrameworkRequestPresenter do
  subject(:presenter) { described_class.new(framework_request) }

  let(:framework_request) { create(:framework_request) }

  describe "#org_name" do
    it "returns the school name" do
      framework_request.organisation = create(:support_organisation, urn: "000001", name: "School #1")
      expect(presenter.org_name).to eq "School #1"
    end
  end

  describe "#dsi?" do
    it "returns true if user_id is present" do
      framework_request.user = build(:user)
      expect(presenter.dsi?).to be true
    end

    it "returns false if user_id is nil" do
      framework_request.user = nil
      expect(presenter.dsi?).to be false
    end
  end

  describe "#user" do
    it "returns user presenter if user exists" do
      framework_request.user = build(:user)
      expect(presenter.user).to be_kind_of UserPresenter
    end

    it "returns OpenStruct if user does not exist" do
      framework_request.user = nil
      expect(presenter.user).to be_kind_of OpenStruct
    end
  end

  describe "#bill_count" do
    before { create_list(:energy_bill, 2, framework_request:) }

    it "returns the number of associted energy bills" do
      expect(presenter.bill_count).to eq 2
    end
  end

  describe "#bill_filenames" do
    before do
      create(:energy_bill, filename: "file1.pdf", framework_request:)
      create(:energy_bill, filename: "file2.pdf", framework_request:)
    end

    it "returns the names of the bill files" do
      expect(presenter.bill_filenames).to eq "file1.pdf, file2.pdf"
    end
  end
end
