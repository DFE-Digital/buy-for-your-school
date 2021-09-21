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
    expect(find("h1.govuk-heading-xl")).to have_text "Create a specification to procure for your school"
  end

  # Who this service is for
  # How this service works
  scenario do
    # specifying.start_page.overview_purpose
    expect(all("p.govuk-body")[0]).to have_text "Use this service to create a specification for a single school in England for either:"
    within(all("ul.govuk-list.govuk-list--bullet")[0]) do
      # specifying.start_page.overview_supported_category_list[0]
      expect(all("li")[0]).to have_text "a catering service, or"
      # specifying.start_page.overview_supported_category_list[1]
      expect(all("li")[1]).to have_text "multi-functional devices"
    end

    # specifying.start_page.overview_download
    expect(all("p.govuk-body")[1]).to have_text "You will be able to download the specification that you create and share it with suppliers when you invite them to bid."

    # specifying.start_page.who_for_title
    expect(all("h2.govuk-heading-l")[0]).to have_text "Who it's for"
    # specifying.start_page.who_for_can_use_body
    expect(all("p.govuk-body")[2]).to have_text "This is for those procuring for one school, either:"
    within(all("ul.govuk-list.govuk-list--bullet")[1]) do
      # specifying.start_page.who_for_can_use_list[0]
      expect(all("li")[0]).to have_text "a local authority maintained school, or"
      # specifying.start_page.who_for_can_use_list[1]
      expect(all("li")[1]).to have_text "one academy within a single or multi-academy trust"
    end

    # specifying.start_page.who_for_cannot_use_body
    expect(all("p.govuk-body")[3]).to have_text "You currently cannot use this service to create a specification for:"
    within(all("ul.govuk-list.govuk-list--bullet")[2]) do
      # specifying.start_page.who_for_cannot_use_list[0]
      expect(all("li")[0]).to have_text "goods or services, other than catering or multi-functional devices"
      # specifying.start_page.who_for_cannot_use_list[1]
      expect(all("li")[1]).to have_text "multiple schools at the same time (this is something we want to add in the future)"
      # specifying.start_page.who_for_cannot_use_list[2]
      expect(all("li")[2]).to have_text "multiple contracts at the same time"
    end

    # specifying.start_page.how_service_works_title
    expect(all("h2.govuk-heading-l")[1]).to have_text "How it works"
    # specifying.start_page.how_service_works_document_body
    expect(all("p.govuk-body")[4]).to have_text "Answer questions to create a document that:"
    within(all("ul.govuk-list.govuk-list--bullet")[3]) do
      # specifying.start_page.how_service_works_document_list[0]
      expect(all("li")[0]).to have_text "describes the service your school is looking for"
      # specifying.start_page.how_service_works_document_list[1]
      expect(all("li")[1]).to have_text "collates all the information that suppliers interested in your contract need to know"
    end

    # specifying.start_page.how_service_works_regulations
    expect(all("p.govuk-body")[5]).to have_text "Standard regulations and requirements that suppliers must comply with will be added automatically – you do not need to know what these are."
    # specifying.start_page.how_service_works_guide
    expect(all("p.govuk-body")[6]).to have_text "The service will guide you through what information to provide."
    # specifying.start_page.how_service_works_secure
    expect(all("p.govuk-body")[7]).to have_text "Information you input is saved securely."

    # specifying.start_page.how_long_it_takes_title
    expect(all("h2.govuk-heading-l")[2]).to have_text "How long it takes"
    # specifying.start_page.how_long_it_takes_body
    expect(all("p.govuk-body")[8]).to have_text "The time it takes to complete a specification varies depending on what you want to include. You can pause and resume your specification at any time."
  end
end
