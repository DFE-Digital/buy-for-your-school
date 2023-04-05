RSpec.describe Support::CreateCaseFormPresenter do
  subject(:presenter) { described_class.new(form) }

  before do
    allow(Support::Category).to receive(:other_category_id).and_return("OTHER_CATEGORY_ID")
    allow(Support::Query).to receive(:other_query_id).and_return("OTHER_QUERY_ID")
  end

  let(:category) { create(:support_category, title: "Catering") }
  let!(:organisation) { create(:support_organisation, name: "Hillside School", urn: "000001") }
  let(:procurement_amount) { nil }

  let(:form_hash) do
    {
      category_id: category.id,
      hub_case_ref: "ce-00001",
      first_name: "first_name",
      last_name: "last_name",
      email: "test@example.com",
      phone_number: "00000000000",
      organisation_id: organisation.id,
      organisation_name: organisation.name,
      organisation_type: organisation.class.to_s,
      procurement_amount:,
    }
  end

  let(:form_schema) { Support::CreateCaseFormSchema.new.call(**form_hash) }
  let(:form) { Support::CreateCaseForm.from_validation(form_schema) }

  describe "#full_name" do
    it "joins first and last name" do
      expect(presenter.full_name).to eq "first_name last_name"
    end
  end

  describe "#category_name" do
    context "when category is provided" do
      it "gives category name from the category id" do
        expect(presenter.category_name).to eq "Catering"
      end
    end

    context "when category is not provided" do
      let(:form_hash) do
        {
          school_urn: "000001",
          hub_case_ref: "ce-00001",
          first_name: "first_name",
          last_name: "last_name",
          email: "test@example.com",
          phone_number: "00000000000",
        }
      end

      it "gives Not Yet Known label" do
        expect(presenter.category_name).to eq "Not applicable"
      end
    end
  end

  describe "#establishment" do
    it "return school from the URN" do
      expect(presenter.organisation).to eq organisation
    end

    it "return schools name" do
      expect(presenter.organisation.name).to eq "Hillside School"
    end
  end

  describe "#procurement_amount" do
    context "when the value is blank" do
      let(:procurement_amount) { nil }

      it "returns an empty string" do
        expect(presenter.procurement_amount).to eq ""
      end
    end

    context "when the value is present" do
      let(:procurement_amount) { "3,450.2" }

      it "returns a formatted currency value" do
        expect(presenter.procurement_amount).to eq "£3,450.20"
      end
    end
  end
end
