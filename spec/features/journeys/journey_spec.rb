RSpec.feature "Journey" do
  let(:user) { create(:user) }
  let(:fixture) { "radio-question.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: setup with factory
    start_journey_from_category(category: fixture)
  end

  scenario "Start page includes a call to action" do
    expect(find("h1.govuk-heading-xl")).to have_text "Create a specification to procure catering for your school"
    expect(find("span.app-task-list__task-name")).to have_text "Radio task"
    expect(find("strong.app-task-list__tag")).to have_text "Not started"
  end

  scenario "an answer must be provided" do
    click_first_link_in_section_list

    # Omit a choice
    click_continue
    expect(find("span.govuk-error-message")).to have_text "can't be blank"
  end

  context "when the Liquid template was invalid" do
    let(:fixture) { "category-with-invalid-liquid-template.json" }

    it "raises an error" do
      expect(find("h1.govuk-heading-xl")).to have_text "An unexpected error occurred"
      expect(find("p.govuk-body")).to have_text "The service has had a problem trying to retrieve a working Specification template. The team have been notified of this problem and you should be able to retry shortly."
    end
  end
end
