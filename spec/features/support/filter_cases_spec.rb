RSpec.feature "Filter cases", bullet: :skip do
  include_context "with an agent"

  let(:catering_cat) { create(:support_category, title: "Catering") }

  before do
    create_list(:support_case, 10)
    click_button "Agent Login"
  end

  it "the my cases 'filter results' form is initially hidden" do
    expect(find("#filter-my-cases")).not_to have_css "show"
  end

  it "the new cases 'filter results' form is initially hidden" do
    expect(find("#filter-new-cases")).not_to have_css "show"
  end

  it "the all cases 'filter results' form is initially hidden" do
    expect(find("#filter-all-cases")).not_to have_css "show"
  end

  describe "filter results button" do
    context "when viewing my cases tab" do
      it "shows the form on click" do
        within "#my-cases" do
          click_button "Filter results"
          expect(find("#filter-my-cases")).to have_css "show"
        end
      end
    end

    context "when viewing new cases tab" do
      it "shows the form on click" do
        within "#new-cases" do
          click_button "Filter results"
          expect(find("#filter-new-cases")).to have_css "show"
        end
      end
    end

    context "when viewing all cases tab" do
      it "shows the form on click" do
        within "#all-cases" do
          click_button "Filter results"
          expect(find("#filter-all-cases")).to have_css "show"
        end
      end
    end
  end
end
