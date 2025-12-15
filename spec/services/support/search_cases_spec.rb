RSpec.describe Support::SearchCases do
  subject(:service) do
    described_class
  end

  let(:organisation_1) { create(:support_organisation, :fixed_urn) }
  let(:organisation_2) { create(:support_organisation, :fixed_name) }

  describe "#search" do
    before do
      create(:support_case, ref: "000999")
      create(:support_case, organisation: organisation_1)
      create(:support_case, organisation: organisation_2)
    end

    let(:search_term) { nil }
    let(:search_params) do
      { search_term: }
    end

    context "when searching by 'search term'" do
      context "when searching for a full URN" do
        let(:search_term) { "12345678" }

        it "returns correct result" do
          expect(service.results(search_params).count).to be(1)
          expect(service.results(search_params).first.organisation.urn).to eq("12345678")
        end
      end

      context "when searching for a partial URN" do
        let(:search_term) { "1234" }

        it "returns correct result" do
          expect(service.results(search_params).count).to be(1)
          expect(service.results(search_params).first.organisation.urn).to eq("12345678")
        end
      end

      context "when searching for a full organisation name" do
        let(:search_term) { "Example School" }

        it "returns correct result" do
          expect(service.results(search_params).count).to be(1)
          expect(service.results(search_params).first.organisation.name).to eq("Example School")
        end
      end

      context "when searching for a partial organisation name" do
        let(:search_term) { "Example" }

        it "returns correct result" do
          expect(service.results(search_params).count).to be(1)
          expect(service.results(search_params).first.organisation.name).to eq("Example School")
        end
      end

      context "when searching for a case ref" do
        let(:search_term) { "000999" }

        it "returns correct result" do
          expect(service.results(search_params).count).to be(1)
          expect(service.results(search_params).first.ref).to eq("000999")
        end
      end
    end
  end
end
