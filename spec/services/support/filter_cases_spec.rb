RSpec.describe Support::FilterCases, bullet: :skip do
  subject(:service) do
    described_class
  end

  let(:ict_tower) { create(:support_tower, title: "ICT") }
  let(:catering_cat) { create(:support_category, title: "Catering") }
  let(:it_cat) { create(:support_category, title: "IT", tower: ict_tower) }
  let(:agent) { create(:support_agent, first_name: "Example Support Agent") }

  before do
    create_list(:support_case, 10)
    create(:support_case, category: it_cat)
    create(:support_case, category: catering_cat, state: :closed, ref: "999888")
    create(:support_case, category: catering_cat, agent:)
  end

  describe "#filter" do
    context "without filtering_params" do
      let(:filtering_params) { nil }

      it "returns all cases except closed cases" do
        results = service.new.filter(filtering_params)

        expect(results.pluck(:ref)).not_to include("999888")
        expect(results.count).to eq(12)
      end
    end

    context "with filter params" do
      context "when filtered by category" do
        let(:filtering_params) do
          { category: it_cat.id }
        end

        it "filters by category" do
          expect(service.new.filter(filtering_params).count).to be(1)
          expect(service.new.filter(filtering_params).first.category.title).to eql("IT")
        end
      end

      context "when filtered by state" do
        let(:filtering_params) do
          { state: :closed }
        end

        it "filters by state" do
          expect(service.new.filter(filtering_params).count).to be(1)
          expect(service.new.filter(filtering_params).first.state).to eql("closed")
        end
      end

      context "when filtered by agent" do
        let(:filtering_params) do
          { agent: agent.id }
        end

        it "filters by agent" do
          expect(service.new.filter(filtering_params).count).to be(1)
          expect(service.new.filter(filtering_params).first.agent.first_name).to eql("Example Support Agent")
        end
      end

      context "when filtered by tower" do
        let(:filtering_params) do
          { tower: ict_tower.id }
        end

        it "filters by tower" do
          expect(service.new.filter(filtering_params).count).to be(1)
          expect(service.new.filter(filtering_params).first.category.tower_title).to eql("ICT")
        end
      end
    end
  end
end
