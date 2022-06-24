require "rails_helper"

describe Support::CollectionHelper do
  describe "#procurement_category_grouped_options" do
    before { define_basic_categories }

    it "does not list 'No applicable category' in the options" do
      expect(helper.procurement_category_grouped_options.flatten).not_to include("No applicable category")
    end

    it "has Or as the last option in the list" do
      expect(helper.procurement_category_grouped_options.last[0]).to eq("Or")
    end

    context "when a category exists with no sub-categories" do
      before { define_categories("Business Services" => []) }

      it "does not show that category in the options" do
        expect(helper.procurement_category_grouped_options.flatten).not_to include("Business Services")
      end
    end
  end
end
