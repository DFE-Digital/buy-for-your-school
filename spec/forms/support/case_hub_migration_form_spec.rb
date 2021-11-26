RSpec.describe Support::CaseHubMigrationForm, type: :model do
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

  # respond to
  it "form params" do
    expect(form.school_urn).to be_nil
    expect(form.contact_first_name).to be_nil
    expect(form.contact_last_name).to be_nil
    expect(form.contact_email).to be_nil
    expect(form.contact_phone_number).to be_nil
    expect(form.buying_category).to be_nil
    expect(form.hub_case_ref).to be_nil
    expect(form.estimated_procurement_completion_date).to be_nil
    expect(form.estimated_savings).to be_nil
    expect(form.hub_notes).to be_nil
    expect(form.progress_notes).to be_nil
  end

  describe "#case_type" do
    context "when hub case ref prefixed with CE- upcase" do
      subject(:form) do
        described_class.new(hub_case_ref: "CE-0001")
      end

      it "is a SW Hub case (2)" do
        expect(form.case_type).to be 2
      end
    end

    context "when hub case ref prefixed with ce- downcase" do
      subject(:form) do
        described_class.new(hub_case_ref: "ce-0001")
      end

      it "is a SW Hub case (2)" do
        expect(form.case_type).to be 2
      end
    end

    context "when hub case ref is anything else" do
      subject(:form) do
        described_class.new(hub_case_ref: "11111")
      end

      it "is a NW Hub case (1)" do
        expect(form.case_type).to be 1
      end
    end
  end

  describe "#to_h" do
    context "when populated" do
      subject(:form) do
        described_class.new(school_urn: "000000", hub_case_ref: "11111")
      end

      it "has values" do
        expect(form.to_h).to eql({
          school_urn: "000000",
          hub_case_ref: "11111",
        })
      end
    end

    context "when unpopulated" do
      it "is empty" do
        expect(form.to_h).to be_empty
      end
    end
  end
end
