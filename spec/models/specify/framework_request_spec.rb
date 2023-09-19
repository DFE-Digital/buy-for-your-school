RSpec.describe FrameworkRequest, type: :model do
  subject(:framework_request) { create(:framework_request, group:, org_id:, is_energy_request:, energy_request_about:, have_energy_bill:, energy_alternative:, school_urns:, category:, contract_length:, contract_start_date_known:, contract_start_date:, same_supplier_used:, document_type_other:) }

  let(:is_energy_request) { false }
  let(:energy_request_about) { nil }
  let(:have_energy_bill) { false }
  let(:energy_alternative) { nil }
  let(:school_urns) { [] }
  let(:group) { false }
  let(:org_id) { nil }
  let(:category) { nil }
  let(:contract_length) { nil }
  let(:contract_start_date_known) { nil }
  let(:contract_start_date) { nil }
  let(:same_supplier_used) { nil }
  let(:document_type_other) { nil }

  it { is_expected.to belong_to(:user).optional }
  it { is_expected.to belong_to(:category).class_name("RequestForHelpCategory").optional }

  describe "#has_bills?" do
    context "when there are associated energy bills" do
      before { create(:energy_bill, framework_request:) }

      it "returns true" do
        expect(framework_request.has_bills?).to eq true
      end
    end

    context "when there are no associated energy bills" do
      it "returns false" do
        expect(framework_request.has_bills?).to eq false
      end
    end
  end

  describe "#selected_schools" do
    before do
      create(:support_organisation, urn: "1", name: "School 1")
      create(:support_organisation, urn: "2", name: "School 2")
      create(:support_organisation, urn: "3", name: "School 3")
    end

    let(:school_urns) { %w[1 2 3] }

    it "returns all selected schools" do
      expect(framework_request.selected_schools.pluck(:name)).to match_array(["School 1", "School 2", "School 3"])
    end
  end

  describe "when the user has selected a SAT" do
    let(:group) { true }
    let(:org_id) { "123" }

    before do
      establishment_group_type = create(:support_establishment_group_type, name: "Single-academy Trust", code: 10)
      create(:support_establishment_group, name: "Single academy trust 1", uid: "123", establishment_group_type:)
      create(:support_organisation, name: "SAT school", urn: "456", trust_code: "123")
    end

    it "automatically persists the school associated with the SAT" do
      framework_request.save!

      expect(framework_request.school_urns).to match_array(%w[456])
    end
  end

  describe "changes to the request category" do
    context "when changed to the 'Goods' flow" do
      let(:category) { create(:request_for_help_category, flow: :services) }
      let(:contract_length) { :three_years }
      let(:contract_start_date_known) { true }
      let(:contract_start_date) { Date.parse("2023-09-20") }
      let(:same_supplier_used) { :yes }
      let(:document_types) { %w[other quotes] }
      let(:document_type_other) { "other" }
      let(:update) { { category: create(:request_for_help_category, flow: :goods) } }

      before do
        framework_request.update!(document_types:)
        create(:energy_bill, framework_request:)
        create(:document, framework_request:)
      end

      it "clears the contract length" do
        expect { framework_request.update!(update) }.to change(framework_request, :contract_length).from(contract_length.to_s).to(nil)
      end

      it "clears the contract start date known" do
        expect { framework_request.update!(update) }.to change(framework_request, :contract_start_date_known).from(contract_start_date_known).to(nil)
      end

      it "clears the contract start date" do
        expect { framework_request.update!(update) }.to change(framework_request, :contract_start_date).from(contract_start_date).to(nil)
      end

      it "clears the 'same supplier used' value" do
        expect { framework_request.update!(update) }.to change(framework_request, :same_supplier_used).from(same_supplier_used.to_s).to(nil)
      end

      it "clears the document types" do
        expect { framework_request.update!(update) }.to change(framework_request, :document_types).from(document_types).to([])
      end

      it "clears the document type other" do
        expect { framework_request.update!(update) }.to change(framework_request, :document_type_other).from(document_type_other).to(nil)
      end

      it "removes all bills" do
        expect { framework_request.update!(update) }.to change { framework_request.reload.energy_bills.count }.from(1).to(0)
      end

      it "removes all documents" do
        expect { framework_request.update!(update) }.to change { framework_request.reload.documents.count }.from(1).to(0)
      end
    end

    context "when changed to the 'Not fully supported' flow" do
      let(:category) { create(:request_for_help_category, flow: nil) }
      let(:contract_length) { :two_years }
      let(:contract_start_date_known) { true }
      let(:contract_start_date) { Date.parse("2025-02-10") }
      let(:same_supplier_used) { :not_sure }
      let(:document_types) { %w[other quotes] }
      let(:document_type_other) { "other" }
      let(:update) { { category: create(:request_for_help_category, flow: :not_fully_supported) } }

      before do
        framework_request.update!(document_types:)
        create_list(:energy_bill, 2, framework_request:)
        create(:document, framework_request:)
      end

      it "clears the contract length" do
        expect { framework_request.update!(update) }.to change(framework_request, :contract_length).from(contract_length.to_s).to(nil)
      end

      it "clears the contract start date known" do
        expect { framework_request.update!(update) }.to change(framework_request, :contract_start_date_known).from(contract_start_date_known).to(nil)
      end

      it "clears the contract start date" do
        expect { framework_request.update!(update) }.to change(framework_request, :contract_start_date).from(contract_start_date).to(nil)
      end

      it "clears the 'same supplier used' value" do
        expect { framework_request.update!(update) }.to change(framework_request, :same_supplier_used).from(same_supplier_used.to_s).to(nil)
      end

      it "clears the document types" do
        expect { framework_request.update!(update) }.to change(framework_request, :document_types).from(document_types).to([])
      end

      it "clears the document type other" do
        expect { framework_request.update!(update) }.to change(framework_request, :document_type_other).from(document_type_other).to(nil)
      end

      it "removes all bills" do
        expect { framework_request.update!(update) }.to change { framework_request.energy_bills.count }.from(2).to(0)
      end

      it "removes all documents" do
        expect { framework_request.update!(update) }.to change { framework_request.reload.documents.count }.from(1).to(0)
      end
    end

    context "when changed to the 'Services' flow" do
      let(:category) { create(:request_for_help_category, flow: :energy) }
      let(:have_energy_bill) { true }
      let(:energy_alternative) { :different_format }
      let(:update) { { category: create(:request_for_help_category, flow: :services) } }

      before { create_list(:energy_bill, 2, framework_request:) }

      it "clears the have energy bill value" do
        expect { framework_request.update!(update) }.to change(framework_request, :have_energy_bill).from(have_energy_bill).to(nil)
      end

      it "clears the energy alternative" do
        expect { framework_request.update!(update) }.to change(framework_request, :energy_alternative).from(energy_alternative.to_s).to(nil)
      end

      it "removes all bills" do
        expect { framework_request.update!(update) }.to change { framework_request.energy_bills.count }.from(2).to(0)
      end
    end

    context "when changed to the 'Energy' flow" do
      let(:category) { create(:request_for_help_category, flow: :services) }
      let(:document_types) { %w[other quotes] }
      let(:document_type_other) { "other" }
      let(:update) { { category: create(:request_for_help_category, flow: :energy) } }

      before do
        framework_request.update!(document_types:)
        create_list(:document, 2, framework_request:)
      end

      it "clears the document types" do
        expect { framework_request.update!(update) }.to change(framework_request, :document_types).from(document_types).to([])
      end

      it "clears the document type other" do
        expect { framework_request.update!(update) }.to change(framework_request, :document_type_other).from(document_type_other).to(nil)
      end

      it "removes all documents" do
        expect { framework_request.update!(update) }.to change { framework_request.documents.count }.from(2).to(0)
      end
    end
  end
end
