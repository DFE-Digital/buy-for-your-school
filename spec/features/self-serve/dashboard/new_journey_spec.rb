RSpec.describe "Creating a new specification" do
  def complete_category_step
    choose "Catering"
    click_continue
  end

  def complete_name_step
    fill_in "new_journey_form[name]", with: "Test specification"
    click_continue
  end

  before do
    # TODO: refactor stubbing here
    persist_category(stub_contentful_category(fixture_filename: "radio-question.json"))
    create(:category, :mfd)
    user_is_signed_in
    visit "/dashboard"
  end

  context "when a user starts a new specification" do
    before do
      click_create
    end

    describe "the category page" do
      it "prompts them to select a category" do
        expect(page.title).to have_text "What are you buying?"
        expect(find("legend.govuk-fieldset__legend--l")).to have_text "What are you buying?"
        expect(page).to have_unchecked_field "Catering"
        expect(page).to have_unchecked_field "Multi-functional devices"
      end

      it "goes back to the dashboard" do
        click_on "Back"

        expect(page).to have_current_path("/dashboard")
      end
    end

    describe "the name page" do
      before do
        complete_category_step
      end

      it "prompts them to enter a name" do
        expect(page.title).to have_text "Name your specification"
        expect(page).to have_field "Name your specification"
        expect(find("div.govuk-hint")).to have_text "This will help you to find it if you need to come back to it later. Use a maximum of 30 characters."
      end

      it "goes back to the category page" do
        click_on "Back"

        expect(page).to have_current_path(/step%5D=2/)
        expect(page).to have_current_path(/back%5D=true/)
        expect(find("legend.govuk-fieldset__legend--l")).to have_text "What are you buying?"
      end
    end

    it "saves the specification with the given category and name" do
      complete_category_step
      complete_name_step

      journey = Journey.first

      expect(journey.name).to eq "Test specification"
      expect(journey.category.title).to eq "Catering"
      expect(page).to have_current_path "/journeys/#{journey.id}"
    end
  end
end
