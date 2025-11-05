RSpec.describe Support::Case, type: :model do
  subject(:support_case) { create(:support_case) }

  it { is_expected.to belong_to(:detected_category).class_name("Support::Category").optional }
  it { is_expected.to belong_to(:procurement_stage).class_name("Support::ProcurementStage").optional }

  it "belongs to a category" do
    expect(support_case.category).not_to be_nil
    expect(support_case.category.title).to match(/support category title \d/)
  end

  it "has optional new and existing contracts" do
    expect(support_case).to belong_to(:new_contract).optional
    expect(support_case).to belong_to(:existing_contract).optional
  end

  it "belongs to an optional procurement" do
    expect(support_case).to belong_to(:procurement).optional
  end

  context "with documents" do
    let!(:document) { create(:support_document, case: support_case) }

    it "has document returned in collection" do
      expect(support_case.documents).not_to be_empty
      expect(support_case.documents.first.document_body).to eql document.document_body
    end
  end

  it { is_expected.to define_enum_for(:support_level).with_values(%i[L1 L2 L3 L4 L5 L6 L7]) }
  it { is_expected.to define_enum_for(:state).with_values(%i[initial opened resolved on_hold closed pipeline no_response]) }
  it { is_expected.to define_enum_for(:source).with_values(%i[digital nw_hub sw_hub incoming_email faf engagement_and_outreach schools_commercial_team engagement_and_outreach_cms energy_onboarding]) }

  describe "#generate_ref" do
    context "when no cases exist" do
      it "generates a reference starting at 1" do
        expect(support_case.ref).to eql "000001"
      end

      it "only generates a reference if none already exists" do
        support_case.save!
        expect(support_case.ref).to eql "000001"
      end
    end

    context "when cases already exist" do
      before do
        create_list(:support_case, 10)
      end

      let!(:new_case) { create(:support_case) }

      it "generates an incrementing reference" do
        expect(new_case.ref).to eql "000011"
      end
    end
  end

  describe ".triage" do
    before do
      create(:support_case, support_level: :L1)
      create(:support_case, support_level: :L2)
      create(:support_case, support_level: :L3)
      create(:support_case, support_level: :L4)
      create(:support_case, support_level: :L5)
    end

    it "returns level 1, 2 and 3 cases" do
      expect(described_class.triage.map(&:support_level)).to match_array(%w[L1 L2 L3])
    end
  end

  describe ".high_level" do
    before do
      create(:support_case, support_level: :L1)
      create(:support_case, support_level: :L2)
      create(:support_case, support_level: :L3)
      create(:support_case, support_level: :L4)
      create(:support_case, support_level: :L5)
    end

    it "returns level 3, 4 and 5 cases" do
      expect(described_class.high_level.map(&:support_level)).to match_array(%w[L3 L4 L5])
    end
  end

  describe "search by_mpan_or_mprn" do
    let(:support_case2) { create(:support_case) }
    let(:onboarding_case) { create(:onboarding_case, support_case:) }
    let(:onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_case.organisation) }
    let(:gas_meter) { create(:energy_gas_meter, :with_valid_data, onboarding_case_organisation:, mprn:) }
    let(:electricity_meter) { create(:energy_electricity_meter, :with_valid_data, onboarding_case_organisation:, mpan:) }

    let(:mprn) { "123456789" }
    let(:mpan) { "0123456789123" }

    context "with gas meter only" do
      before do
        gas_meter
      end

      it "finds case by mprn (gas meter)" do
        results = described_class.by_mpan_or_mprn(mprn)
        expect(results).to include(support_case)
        expect(results).not_to include(support_case2)
      end
    end

    context "with electricity meter only" do
      before do
        electricity_meter
      end

      it "finds case by mpan (electricity meter)" do
        results = described_class.by_mpan_or_mprn(mpan)
        expect(results).to include(support_case)
        expect(results).not_to include(support_case2)
      end
    end

    context "with both gas and electricity meters" do
      before do
        gas_meter
        electricity_meter
      end

      it "finds case by mprn (gas meter)" do
        results = described_class.by_mpan_or_mprn(mprn)
        expect(results).to include(support_case)
        expect(results).not_to include(support_case2)
      end

      it "finds case by mpan (electricity meter)" do
        results = described_class.by_mpan_or_mprn(mpan)
        expect(results).to include(support_case)
        expect(results).not_to include(support_case2)
      end

      it "returns empty when term doesn't match" do
        results = described_class.by_mpan_or_mprn("000000000")
        expect(results).to be_empty
      end
    end
  end

  describe "re_used_meter_numbers?" do
    before do
      support_case.update!(state: "closed")

      create(:energy_gas_meter, :with_valid_data, onboarding_case_organisation: ob_org, mprn:)
      create(:energy_electricity_meter, :with_valid_data, onboarding_case_organisation: ob_org, mpan:)
    end

    let(:ob_case) { create(:onboarding_case, support_case:) }
    let(:ob_org) { create(:energy_onboarding_case_organisation, onboarding_case: ob_case, onboardable: support_case.organisation) }
    let(:mprn) { "123456789" }
    let(:mpan) { "0123456789123" }

    context "when another active onboarding case is using a meter ref" do
      before do
        create(:energy_gas_meter, :with_valid_data, onboarding_case_organisation: other_onboarding_case_organisation, mprn:)
        create(:energy_electricity_meter, :with_valid_data, onboarding_case_organisation: other_onboarding_case_organisation, mpan:)
      end

      let(:other_onboarding_case) { create(:onboarding_case, support_case: other_support_case) }
      let(:other_onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case: other_onboarding_case, onboardable: other_support_case.organisation) }

      context "when the state is not closed" do
        let(:other_support_case) { create(:support_case) }

        it "returns true" do
          expect(support_case.re_used_meter_numbers?).to eq(true)
        end
      end

      context "when the state is closed" do
        let(:other_support_case) { create(:support_case, state: "closed") }

        it "returns false" do
          expect(support_case.re_used_meter_numbers?).to eq(false)
        end
      end
    end

    context "when no other active onboarding cases are using a meter ref" do
      it "returns false" do
        expect(support_case.re_used_meter_numbers?).to eq(false)
      end
    end
  end
end
