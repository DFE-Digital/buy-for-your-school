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
    expect(form.first_name).to be_nil
    expect(form.last_name).to be_nil
    expect(form.email).to be_nil
    expect(form.phone_number).to be_nil
    expect(form.category_id).to be_nil
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
        expect(form.case_type).to eq "sw_hub"
      end
    end

    context "when hub case ref prefixed with ce- downcase" do
      subject(:form) do
        described_class.new(hub_case_ref: "ce-0001")
      end

      it "is a SW Hub case (2)" do
        expect(form.case_type).to eq "sw_hub"
      end
    end

    context "when hub case ref lies between 1000 and 99999" do
      subject(:form) do
        described_class.new(hub_case_ref: "1000")
      end

      it "is a NW Hub case" do
        expect(form.case_type).to eq "nw_hub"
      end
    end

    context "when hub case ref is anything else" do
      subject(:form) do
        described_class.new(hub_case_ref: "111111")
      end

      it "is null" do
        expect(form.case_type).to be_nil
      end
    end
  end

  describe "#to_h" do
    context "when populated" do
      subject(:form) do
        described_class.new(school_urn: "000000", hub_case_ref: "11111", source: "nw_hub")
      end

      it "has values" do
        expect(form.to_h).to eql({
          school_urn: "000000",
          hub_case_ref: "11111",
          source: "nw_hub",
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
