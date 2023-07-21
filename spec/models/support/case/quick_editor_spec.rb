require "rails_helper"

describe Support::Case::QuickEditor do
  subject(:quick_editor) { described_class.new(params) }

  describe "#procurement_case?" do
    context "when the case has a category" do
      let(:params) { { support_case: create(:support_case, category: create(:support_category)) } }

      it "returns true" do
        expect(quick_editor.procurement_case?).to eq(true)
      end
    end

    context "when the case does not have a category" do
      let(:params) { { support_case: create(:support_case, category: nil) } }

      it "returns false" do
        expect(quick_editor.procurement_case?).to eq(false)
      end
    end
  end
end
