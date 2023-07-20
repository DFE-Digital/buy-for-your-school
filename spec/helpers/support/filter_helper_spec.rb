require "rails_helper"

describe Support::FilterHelper do
  describe "#toggle_visibility?" do
    let(:key) { :filter_form }
    let(:form) { double("filter_form", filters_selected?: true) }
    let(:params) { { filter_form: { x: 1 } } }
    let(:session) { {} }

    before do
      described_class.define_method(:cached_filter_params_for) { |cache_key| session[cache_key] }
      allow(helper).to receive(:params).and_return(params)
      allow(helper).to receive(:session).and_return(session)
    end

    context "when filtering key param present" do
      it "displays the filter form" do
        expect(helper.toggle_visibility?(key)).to eq("govuk-!-display-block")
      end
    end

    context "when cached filtering params are preseent" do
      let(:params) { {} }
      let(:session) { { filter_form: { x: 1 } } }

      it "displays the filter form" do
        expect(helper.toggle_visibility?(key)).to eq("govuk-!-display-block")
      end
    end

    context "when neither params key, nor cached params are present" do
      let(:params) { {} }
      let(:session) { {} }

      it "hides the filter form" do
        expect(helper.toggle_visibility?(key)).to eq("govuk-!-display-none")
      end
    end
  end

  describe "#available_categories" do
    let(:tower) { create(:support_tower) }

    before do
      create(:support_category, tower:, title: "Tower Cat 1")
      create(:support_category, tower:, title: "Tower Cat 2")
      create(:support_category, tower: nil, title: "Non-Tower Cat 1")
      create(:support_category, tower: nil, title: "Non-Tower Cat 2")
    end

    context "when a tower is provided" do
      it "only returns the categories in that tower" do
        expect(available_categories(tower).pluck(:title)).to match_array([
          "Tower Cat 1", "Tower Cat 2"
        ])
      end
    end

    context "when no tower is provided" do
      it "returns all categories" do
        expect(available_categories.pluck(:title)).to match_array([
          "Tower Cat 1",
          "Tower Cat 2",
          "Non-Tower Cat 1",
          "Non-Tower Cat 2",
        ])
      end
    end
  end
end
