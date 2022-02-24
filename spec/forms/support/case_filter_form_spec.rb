RSpec.describe Support::CaseFilterForm, type: :model do
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
end
