RSpec.describe Support::CaseSearchForm, type: :model do
  subject(:form) { described_class.new }

  it "#messages" do
    expect(form.messages).to be_a Hash
    expect(form.messages).to be_empty
    expect(form.errors.messages).to be_a Hash
    expect(form.errors.messages).to be_empty
  end

  it "#errors" do
    expect(form.errors).to be_a Support::Concerns::ErrorSummary
    expect(form.errors.any?).to be false
  end

  it "form params" do
    expect(form.search_term).to be_nil
  end

  describe "#ransack_params" do
    context "when nil" do
      subject(:form) do
        described_class.new(ransack_params: nil)
      end

      it "returns nil" do
        expect(form.ransack_params).to be nil
      end
    end

    context "when search term provided" do
      subject(:form) do
        described_class.new(search_term: "test")
      end

      it "returns ransack params as a hash" do
        expect(form.ransack_params).to eql({ ref_or_organisation_urn_or_organisation_name_cont: "test" })
      end
    end
  end
end
