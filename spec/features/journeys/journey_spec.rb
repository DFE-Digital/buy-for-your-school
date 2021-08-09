RSpec.feature "Journey" do
  let(:user) { create(:user) }
  let(:fixture) { "radio-question.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: setup with factory
    start_journey_from_category(category: fixture)
  end

  scenario "Start page includes a call to action" do
    # /journeys/302e58f4-01b3-469a-906e-db6991184699
    expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})}

    expect(find("h1.govuk-heading-xl")).to have_text "Create a specification to procure catering for your school"
    expect(find("span.app-task-list__task-name")).to have_text "Radio task"
    expect(find("strong.app-task-list__tag")).to have_text "Not started"
  end

  scenario "an answer must be provided" do
    click_first_link_in_section_list

    # Omit a choice
    click_continue

    # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d/answers
    expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/steps/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/answers}
    expect(find("span.govuk-error-message")).to have_text "can't be blank"
  end

  context "when the Liquid template was invalid" do
    let(:fixture) { "category-with-invalid-liquid-template.json" }

    it "raises an error" do
      expect(page).to have_current_path "/journeys"
      expect(find("h1.govuk-heading-xl")).to have_text "An unexpected error occurred"
      expect(find("p.govuk-body")).to have_text "The service has had a problem trying to retrieve a working Specification template. The team have been notified of this problem and you should be able to retry shortly."
    end
  end
end
