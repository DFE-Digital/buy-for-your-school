RSpec.feature "Content Designers can see" do
  before do
    user_is_signed_in
  end

  context "when there are no categories" do
    before do
      stub_multiple_contentful_categories(category_fixtures: [])
      visit "/design"
    end

    it "categories.not_found" do
      expect(find("h1.govuk-heading-l")).to have_text "No categories found"
    end
  end

  context "when there are categories" do
    let(:catering_fixture) { "journey-with-multiple-entries" }
    let(:mfd_fixture) { "mfd-radio-question" }

    before do
      stub_multiple_contentful_categories(category_fixtures: [
        catering_fixture,
        mfd_fixture,
      ])
      visit "/design"
    end

    specify "page title" do
      expect(page.title).to have_text "Choose a category"
    end

    it "design.category_selection_header" do
      expect(find("h1.govuk-heading-xl")).to have_text "Choose a category"
    end

    it "lists expected categories" do
      within("ul.govuk-list.govuk-list--bullet") do
        list_items = find_all("li")

        expect(list_items[0]).to have_link "Catering", href: "/design/catering", class: "govuk-link"
        expect(list_items[1]).to have_link "Multi-function devices", href: "/design/mfd", class: "govuk-link"
      end
    end
  end
end
