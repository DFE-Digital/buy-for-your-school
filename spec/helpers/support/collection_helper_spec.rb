require "rails_helper"

describe Support::CollectionHelper do
  describe "#procurement_category_grouped_options" do
    it "does not list 'No applicable category' in the options" do
      allow(Support::Category).to receive(:grouped_opts).and_return({
        "ICT" => {
          "Peripherals" => 1
        },
        "Or" => {
          "Other" => 2,
          "No applicable category" => 3
        }
      })

      expect(helper.procurement_category_grouped_options.flatten).not_to include("No applicable category")
    end
  end
end
