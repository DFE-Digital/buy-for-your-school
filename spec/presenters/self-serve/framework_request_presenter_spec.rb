RSpec.describe FrameworkRequestPresenter do
  let(:framework_request) { build(:framework_request) }

  describe "#school_name" do
    it "returns the school name" do
      create(:support_organisation, urn: "000001", name: "School #1")
      presenter = described_class.new(framework_request)
      expect(presenter.school_name).to eq "School #1"
    end
  end

  describe "#dsi?" do
    it "returns true if user_id is present" do
      framework_request.user = build(:user)
      presenter = described_class.new(framework_request)
      expect(presenter.dsi?).to be true
    end

    it "returns false if user_id is nil" do
      framework_request.user = nil
      presenter = described_class.new(framework_request)
      expect(presenter.dsi?).to be false
    end
  end

  describe "#user" do
    it "returns user presenter if user exists" do
      framework_request.user = build(:user)
      presenter = described_class.new(framework_request)
      expect(presenter.user).to be_kind_of UserPresenter
    end

    it "returns OpenStruct if user does not exist" do
      framework_request.user = nil
      presenter = described_class.new(framework_request)
      expect(presenter.user).to be_kind_of OpenStruct
    end
  end
end
