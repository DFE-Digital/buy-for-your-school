describe FrameworkRequests::SearchForOrganisationForm, type: :model do
  subject(:form) { described_class.new(id: framework_request.id) }

  let(:framework_request) { create(:framework_request, organisation: nil) }

  let!(:organisation) { create(:support_organisation) }

  shared_examples "validation error assertion" do |error_message|
    it "returns the right error message" do
      expect(form).not_to be_valid
      expect(form.errors.messages[:organisation_id]).to eq [error_message]
    end
  end

  describe "#organisation_id_validation" do
    before { form.organisation_id_validation }

    context "when no school is selected" do
      subject(:form) { described_class.new(id: framework_request.id, school_type: "school") }

      include_examples "validation error assertion", "Select the school you want help buying for"
    end

    context "when an invalid school is selected" do
      subject(:form) { described_class.new(id: framework_request.id, organisation_id: "invalid", school_type: "school") }

      include_examples "validation error assertion", "Select the school you want help buying for"
    end

    context "when no group is selected" do
      subject(:form) { described_class.new(id: framework_request.id, school_type: "group") }

      include_examples "validation error assertion", "Enter your academy trust or federation name, or UKPRN and select it from the list"
    end

    context "when an invalid group is selected" do
      subject(:form) { described_class.new(id: framework_request.id, organisation_id: "invalid", school_type: "group") }

      include_examples "validation error assertion", "Enter your academy trust or federation name, or UKPRN and select it from the list"
    end
  end

  describe "#find_other_type" do
    subject(:form) { described_class.new(id: framework_request.id, school_type: "school", organisation_id: organisation.id, organisation_type: organisation.class.name) }

    it "returns flipped group value and nil organisation_id" do
      expect(form.find_other_type).to eq({ school_type: "group", organisation_id: nil })
    end
  end

  describe "#flipped_school_type" do
    context "when the school type is a single school" do
      subject(:form) { described_class.new(id: framework_request.id, school_type: "school") }

      it "returns group" do
        expect(form.flipped_school_type).to eq "group"
      end
    end

    context "when the school type is a group" do
      subject(:form) { described_class.new(id: framework_request.id, school_type: "group") }

      it "returns school" do
        expect(form.flipped_school_type).to eq "school"
      end
    end
  end

  describe "#changing_school_types?" do
    context "when chanigng from single school to group" do
      subject(:form) { described_class.new(id: framework_request.id, school_type: "group") }

      let(:framework_request) { create(:framework_request, group: false) }

      it "returns true" do
        expect(form.changing_school_types?).to eq true
      end
    end

    context "when chanigng from group to single school" do
      subject(:form) { described_class.new(id: framework_request.id, school_type: "school") }

      let(:framework_request) { create(:framework_request, group: true) }

      it "returns true" do
        expect(form.changing_school_types?).to eq true
      end
    end
  end
end
