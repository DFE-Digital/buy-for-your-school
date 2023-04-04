RSpec.describe Support::CaseFilterForm, type: :model do
  subject(:form) { described_class.new(**form_fields) }

  let(:form_fields) { {} }

  describe "#results" do
    let!(:closed_case) { create(:support_case, :closed) }
    let!(:opened_case) { create(:support_case, :opened) }

    around do |example|
      Bullet.enable = false
      example.run
      Bullet.enable = true
    end

    context "when specifying a state of closed" do
      it "returns closed cases" do
        results = described_class.new(state: "closed").results
        expect(results).to include(closed_case)
        expect(results).not_to include(opened_case)
      end
    end

    it "doesnt return any closed cases" do
      results = described_class.new.results
      expect(results).to include(opened_case)
      expect(results).not_to include(closed_case)
    end
  end

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
    expect(form.state).to be_nil
    expect(form.category).to be_nil
    expect(form.agent).to be_nil
  end

  describe "#agents" do
    before do
      create(:support_agent, first_name: "Example", last_name: "Support Agent")
    end

    it "returns array of decorated agents" do
      expect(form.agents.first.full_name).to eql("Example Support Agent")
    end
  end

  describe "#categories" do
    before do
      create(:support_category, title: "Example Category (No Cases)")
      create(:support_case, :with_fixed_category)
    end

    it "returns only categories that have cases attached" do
      expect(form.categories.count).to be(1)
      expect(form.categories.first.title).to eql("Fixed Category")
    end
  end

  describe "#filters_selected?" do
    context "when only default fields are set" do
      let(:form_fields) { { stage: "need", defaults: { stage: "need" } } }

      it "returns false" do
        expect(form.filters_selected?).to eq false
      end
    end

    context "when no fields are set" do
      let(:form_fields) { {} }

      it "returns false" do
        expect(form.filters_selected?).to eq false
      end
    end

    context "when more than default fields are set" do
      let(:form_fields) { { level: "L1", stage: "need", defaults: { stage: "need" } } }

      it "returns true" do
        expect(form.filters_selected?).to eq true
      end
    end
  end
end
