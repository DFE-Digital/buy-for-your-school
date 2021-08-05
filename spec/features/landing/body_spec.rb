RSpec.feature "Users can see a start page" do
  before do
    visit "/"
  end

  it "has a start button to login" do
    within "main.govuk-main-wrapper" do
      expect(find("form.button_to")["action"]).to eql "/auth/dfe"
      # generic.button.start
      expect(page).to have_button "Start", class: "govuk-button"
    end
  end

  it "has a heading" do
    expect(find("h1.govuk-heading-xl")).to have_text "Create a specification to procure something for your school"
  end

  it "links to catering procurements" do
    expect(page).to have_link("procuring a new catering service", href: "https://buy-for-your-school-prototypes.herokuapp.com/beta/phase-5/catering")
  end

  # Who this service is for
  # How this service works
  # TODO: replace with raw strings and find tags
  scenario do
    I18n.t("specifying.start_page.overview_body").each do |paragraph|
      expect(page).to have_content(paragraph)
    end

    expect(page).to have_content(I18n.t("specifying.start_page.who_for_title"))
    expect(page).to have_content(I18n.t("specifying.start_page.who_for_can_use_body"))

    expect(page).to have_content("are responsible for procuring a new catering service for a school")

    expect(page).to have_content(I18n.t("specifying.start_page.who_for_can_use_list")[1])
    expect(page).to have_content(I18n.t("specifying.start_page.who_for_can_use_list")[2])

    expect(page).to have_content(I18n.t("specifying.start_page.who_for_cannot_use_body"))

    I18n.t("specifying.start_page.who_for_cannot_use_list").each do |list_item|
      expect(page).to have_content(list_item)
    end

    expect(page).to have_content(I18n.t("specifying.start_page.how_service_works_title"))
    expect(page).to have_content(I18n.t("specifying.start_page.how_service_works_document_body"))

    I18n.t("specifying.start_page.how_service_works_document_list").each do |list_item|
      expect(page).to have_content(list_item)
    end

    expect(page).to have_content(I18n.t("specifying.start_page.how_service_works_themes_body"))

    I18n.t("specifying.start_page.how_service_works_themes_list").each do |list_item|
      expect(page).to have_content(list_item)
    end

    expect(page).to have_content(I18n.t("specifying.start_page.pause_and_resume_body"))
  end
end
