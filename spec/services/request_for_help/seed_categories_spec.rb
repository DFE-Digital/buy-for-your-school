require "rails_helper"

describe RequestForHelp::SeedCategories do
  subject(:service) { described_class.new }

  let(:categories) { RequestForHelpCategory.where(parent_id: nil) }
  let(:sub_categories) { RequestForHelpCategory.where.not(parent_id: nil) }

  it "populates the table" do
    expect { service.call }
      .to change(categories, :count).from(0).to(15)
      .and change(sub_categories, :count).from(0).to(99)
  end

  context "when a category has sub-categories" do
    before { service.call }

    it "nests the sub-categories under the parent" do
      transport = RequestForHelpCategory.find_by(title: "Transport")
      sub_categories = transport.sub_categories.pluck(:title)
      passenger_transport_category = RequestForHelpCategory.find_by(title: "Passenger transport")

      expect(sub_categories).to include("Vehicle hire or purchase")
      expect(sub_categories).to include("Other")
      expect(passenger_transport_category.parent.title).to eq("Transport")
    end
  end

  context "when a category maps to a support category" do
    before { service.call }

    it "stores reference to to the support category" do
      passenger_transport = RequestForHelpCategory.find_by(title: "Passenger transport")
      support_category = Support::Category.find_by(title: "Passenger transport")

      expect(passenger_transport.support_category).to eq(support_category)
    end
  end
end
