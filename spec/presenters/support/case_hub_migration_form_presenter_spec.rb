RSpec.describe Support::CaseHubMigrationFormPresenter do
  subject(:presenter) { described_class.new(form) }

  let(:category) { create(:support_category, title: "Catering") }
  let!(:organisation) { create(:support_organisation, name: "Hillside School", urn: "000001") }

  let(:form_hash) do
    {
      category_id: category.id,
      school_urn: "000001",
      hub_case_ref: "ce-00001",
      first_name: "first_name",
      last_name: "last_name",
      email: "test@example.com",
      phone_number: "00000000000",
    }
  end

  let(:form_schema) { Support::CaseHubMigrationFormSchema.new.call(**form_hash) }
  let(:form) { Support::CaseHubMigrationForm.from_validation(form_schema) }

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
        expect(presenter.category_name).to eq "Not Yet Known"
      end
    end
  end

  describe "#establishment" do
    it "return school from the URN" do
      expect(presenter.establishment).to eq organisation
    end

    it "return schools name" do
      expect(presenter.establishment.name).to eq "Hillside School"
    end
  end
end
