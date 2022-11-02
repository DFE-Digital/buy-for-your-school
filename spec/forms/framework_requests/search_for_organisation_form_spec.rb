describe FrameworkRequests::SearchForOrganisationForm, type: :model do
  subject(:form) { described_class.new(id: framework_request.id) }

  let(:framework_request) { create(:framework_request, org_id: nil) }

  describe "#org_id_validation" do
    context "when no school is selected" do
      subject(:form) { described_class.new(id: framework_request.id, school_type: "school") }

      it "returns the right error message" do
        form.org_id_validation

        expect(form).not_to be_valid
        expect(form.errors.messages[:org_id]).to eq ["Select the school you want help buying for"]
      end
    end

    context "when no group is selected" do
      subject(:form) { described_class.new(id: framework_request.id, school_type: "group") }

      it "returns the right error message" do
        form.org_id_validation

        expect(form).not_to be_valid
        expect(form.errors.messages[:org_id]).to eq ["Enter your academy trust or federation name, or UKPRN and select it from the list"]
      end
    end
  end

  describe "#find_other_type" do
    subject(:form) { described_class.new(id: framework_request.id, school_type: "school", org_id: "123 - Organisation") }

    it "returns flipped group value and nil org_id" do
      expect(form.find_other_type).to eq({ school_type: "group", org_id: nil })
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

  describe "#formatted_org_name" do
    context "when the org_id is not set" do
      it "returns nil" do
        expect(form.formatted_org_name).to be nil
      end
    end

    context "when the org_id is set" do
      let(:framework_request) { create(:framework_request, org_id: "123", group: false) }

      before { create(:support_organisation, urn: "123", name: "Test School") }

      it "returns a formatted org_id with the organisation name" do
        expect(form.formatted_org_name).to eq "123 - Test School"
      end
    end
  end
end
