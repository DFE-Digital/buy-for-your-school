describe Support::Case::Filterable do
  subject(:filterable) { Support::Case }

  let(:ict_tower) { create(:support_tower, title: "ICT") }
  let(:catering_cat) { create(:support_category, title: "Catering") }
  let(:it_cat) { create(:support_category, title: "IT", tower: ict_tower) }
  let(:agent) { create(:support_agent, first_name: "Example Support Agent") }

  before do
    create_list(:support_case, 10)
    create(:support_case, category: it_cat, organisation: nil)
    create(:support_case, category: catering_cat, state: :closed, ref: "999888")
    create(:support_case, category: catering_cat, state: :on_hold, agent:)
  end

  describe ".filtered_by" do
    context "with filter params" do
      let(:filtering_params) do
        { category: [catering_cat.id] }
      end

      it "does not return closes cases by default" do
        expect(filterable.filtered_by(filtering_params).count).to be(1)
        expect(filterable.filtered_by(filtering_params).first.state).to eql("on_hold")
      end

      context "when filtered by category" do
        let(:filtering_params) do
          { category: [it_cat.id] }
        end

        it "filters by category" do
          expect(filterable.filtered_by(filtering_params).count).to be(1)
          expect(filterable.filtered_by(filtering_params).first.category.title).to eql("IT")
        end
      end

      context "when filtered by state" do
        let(:filtering_params) do
          { state: %i[closed on_hold] }
        end

        it "filters by state" do
          results = filterable.filtered_by(filtering_params)

          expect(results.count).to be(2)
          expect(results.pluck(:state)).to match_array(%w[closed on_hold])
        end
      end

      context "when filtered by agent" do
        let(:filtering_params) do
          { agent: [agent.id] }
        end

        it "filters by agent" do
          expect(filterable.filtered_by(filtering_params).count).to be(1)
          expect(filterable.filtered_by(filtering_params).first.agent.first_name).to eql("Example Support Agent")
        end
      end

      context "when filtered by tower" do
        let(:filtering_params) do
          { tower: [ict_tower.id] }
        end

        it "filters by tower" do
          expect(filterable.filtered_by(filtering_params).count).to be(1)
          expect(filterable.filtered_by(filtering_params).first.category.tower_title).to eql("ICT")
        end
      end

      context "when filtered by has_org" do
        let(:filtering_params) do
          { has_org: false }
        end

        it "filters by has_org" do
          expect(filterable.filtered_by(filtering_params).count).to be(1)
          expect(filterable.filtered_by(filtering_params).first.category.tower_title).to eql("ICT")
        end
      end

      context "when search_term is provided" do
        let(:filtering_params) do
          { search_term: "999888" }
        end

        it "returns closed cases metching the criteria" do
          expect(filterable.filtered_by(filtering_params).count).to be(1)
          expect(filterable.filtered_by(filtering_params).first.state).to eql("closed")
        end
      end
    end
  end
end
