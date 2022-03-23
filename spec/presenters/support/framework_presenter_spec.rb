RSpec.describe Support::FrameworkPresenter do
  subject(:presenter) { described_class.new(framework) }

  describe "#expires_at" do
    context "when present" do
      let(:framework) { build(:support_framework, expires_at: "2023-04-15") }

      it "returns the formatted expiry date" do
        expect(presenter.expires_at).to eq "15 April 2023"
      end
    end

    context "when nil" do
      let(:framework) { build(:support_framework, expires_at: nil) }

      it "returns a hyphen" do
        expect(presenter.expires_at).to eq "-"
      end
    end
  end

  describe "#as_json" do
    let(:framework) { build(:support_framework, expires_at: "2023-04-15") }

    it "returns the formatted expiry date" do
      expect(presenter.as_json).to include(
        "expires_at" => "15 April 2023",
      )
    end
  end
end
