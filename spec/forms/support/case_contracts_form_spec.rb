RSpec.describe Support::CaseContractsForm, type: :model do
  subject(:form) { described_class.new }

  it "#messages" do
    expect(form.messages).to be_a Hash
    expect(form.messages).to be_empty
    expect(form.errors.messages).to be_a Hash
    expect(form.errors.messages).to be_empty
  end

  it "#errors" do
    expect(form.errors).to be_a Support::Form::ErrorSummary
    expect(form.errors.any?).to be false
  end

  # respond to
  it "form params" do
    expect(form.supplier).to be_nil
    expect(form.started_at).to be_nil
    expect(form.ended_at).to be_nil
    expect(form.spend).to be_nil
    expect(form.duration).to be_nil
  end

  describe "#duration" do
    context "when nil" do
      subject(:form) do
        described_class.new(duration: nil)
      end

      it "returns nil" do
        expect(form.duration).to be_nil
      end

      it { expect(form.to_h).to eq({ duration: nil }) }
    end

    context "when duration an Integer" do
      subject(:form) do
        described_class.new(duration: 12)
      end

      it "returns duration as an integer" do
        expect(form.duration).to be 12
      end

      it { expect(form.to_h).to eql({ duration: 12.months }) }
    end
  end

  describe "#to_h" do
    subject(:form) { described_class.new(duration:) }

    context "when duration is nil" do
      let(:duration) { nil }

      it "returns nil" do
        expect(form.to_h[:duration]).to be_nil
      end
    end

    context "when duration is an Integer" do
      let(:duration) { 12 }

      it "duration returns ActiveSupport::Duration" do
        expect(form.to_h[:duration]).to eql 12.months
        expect(form.to_h[:duration]).to be_a ActiveSupport::Duration
      end
    end
  end
end
