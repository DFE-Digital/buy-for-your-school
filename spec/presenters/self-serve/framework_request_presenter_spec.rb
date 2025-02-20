RSpec.describe FrameworkRequestPresenter do
  subject(:presenter) { described_class.new(framework_request) }

  let(:framework_request) { create(:framework_request) }

  describe "#org_name" do
    it "returns the school name" do
      create(:support_organisation, urn: "000001", name: "School #1")
      expect(presenter.org_name).to eq "School #1"
    end
  end

  describe "#dsi?" do
    it "returns true if user_id is present" do
      framework_request.user = create(:user)
      expect(presenter.dsi?).to be true
    end

    it "returns false if user_id is nil" do
      framework_request.user = nil
      expect(presenter.dsi?).to be false
    end
  end

  describe "#user" do
    it "returns user presenter if user exists" do
      framework_request.user = create(:user)
      expect(presenter.user).to be_a UserPresenter
    end

    it "returns OpenStruct if user does not exist" do
      framework_request.user = nil
      expect(presenter.user).to be_a OpenStruct
    end
  end

  describe "#bill_count" do
    before { create_list(:energy_bill, 2, framework_request:) }

    it "returns the number of associated energy bills" do
      expect(presenter.bill_count).to eq 2
    end
  end

  describe "#bill_filenames" do
    before do
      create(:energy_bill, filename: "file1.pdf", framework_request:)
      create(:energy_bill, filename: "file2.pdf", framework_request:)
    end

    it "returns the names of the bill files" do
      expect(presenter.bill_filenames).to eq "file1.pdf, file2.pdf"
    end
  end

  describe "#document_filenames" do
    before do
      create(:document, filename: "file1.pdf", framework_request:)
      create(:document, filename: "file2.pdf", framework_request:)
    end

    it "returns the names of the document files" do
      expect(presenter.document_filenames).to eq "file1.pdf, file2.pdf"
    end
  end

  describe "#org_name_or_number" do
    let(:framework_request) { create(:framework_request, group: true, org_id: "abc") }

    context "when there are school urns within framework request" do
      before do
        framework_request.update!(school_urns: %w[1 2])
        create(:support_establishment_group, uid: "abc", establishment_group_type: create(:support_establishment_group_type, code: 2))
        create(:support_organisation, urn: "1", trust_code: "abc")
        create(:support_organisation, urn: "2", trust_code: "abc")
        create(:support_organisation, urn: "3", trust_code: "abc")
      end

      it "returns the number of schools selected out of the available schools" do
        expect(presenter.org_name_or_number).to eq "2 out of 3 schools"
      end
    end

    context "when there are no school urns within framework request" do
      context "and the organisation is a single school" do
        it "returns the school name" do
          framework_request.update!(group: false, org_id: "000001")
          create(:support_organisation, urn: "000001", name: "School #1")
          expect(presenter.org_name_or_number).to eq "School #1"
        end
      end

      context "and the organisation is a group"
      it "returns the group name" do
        framework_request.update!(group: true, org_id: "123")
        create(:support_establishment_group, uid: "123", name: "Group #1")
        expect(presenter.org_name_or_number).to eq "Group #1"
      end
    end
  end
end
