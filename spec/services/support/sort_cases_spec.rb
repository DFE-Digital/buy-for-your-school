RSpec.describe Support::SortCases do
  subject(:service) { described_class.new(nil) }

  describe "#sort" do
    context "when there are no sorting parameters" do
      it "orders by action" do
        allow(Support::Case).to receive(:order_by_action)
        service.sort(nil)
        expect(Support::Case).to have_received(:order_by_action)
      end
    end

    context "when there are sorting parameters" do
      it "delegates to the model" do
        allow(Support::Case).to receive(:order_by_ref).with("DESC")
        service.sort({ ref: "descending" })
        expect(Support::Case).to have_received(:order_by_ref).with("DESC")
      end
    end
  end
end
