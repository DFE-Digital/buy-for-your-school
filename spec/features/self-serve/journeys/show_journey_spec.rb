RSpec.feature "A journey page has" do
  let(:user) { create(:user) }
  let(:category) { create(:category, :catering) }

  before do
    journey = create(:journey, category: category, user: user)
    user_is_signed_in(user: user)
    visit("/journeys/#{journey.id}")
  end

  it "shows the specification name" do
    expect(page).to have_text "You are editing: test spec"
  end

  specify "breadcrumbs" do
    expect(page).to have_breadcrumbs ["Dashboard", "Create specification"]
  end

  specify do
    expect(page).to have_a_journey_path
  end

  specify do
    expect(page).to have_title "test spec"
  end

  # specifying.start_page.page_title
  specify "heading" do
    expect(find("h1.govuk-heading-xl")).to have_text "Edit your specification to procure catering for your school"
  end

  specify do
    # journeys_body
    expect(find("p.govuk-body")).to have_text "Answer all questions in each section to create a specification to share with suppliers. You can work through the sections in any order, and come back to questions later by skipping those you can't answer yet. View your specification at any time."
  end
end
