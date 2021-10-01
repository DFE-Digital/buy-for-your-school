RSpec.feature "Users can see a start page for planning their purchase" do
  scenario "Start page content is shown on the root path" do
    visit "/planning"

    expect(find("h1.govuk-heading-xl")).to have_text "Catering services"
    expect(all("p.govuk-body")[0]).to have_text "How to procure a catering contract for your school."

    within("div.govuk-accordion") do
      expect(all("span.govuk-accordion__section-button")[0]).to have_text "Before you start"
      within("div#accordion-default-content-1") do
        expect(all("p.govuk-body")[0]).to have_text "A catering contract typically takes between 3 to 6 months to complete."
      end

      expect(all("span.govuk-accordion__section-button")[1]).to have_text "Ways to procure a catering contract"
      within("div#accordion-default-content-2") do
        expect(all("p.govuk-body")[0]).to have_text "A catering contract is a high value procurement. We generally say high is over 40,000."
      end

      expect(all("span.govuk-accordion__section-button")[2]).to have_text "Rules, regulations and requirements"
      within("div#accordion-default-content-3") do
        expect(all("p.govuk-body")[0]).to have_text "You'll need to be aware of some of the rules, regulations and requirements that can apply to a catering contract."
      end

      expect(all("span.govuk-accordion__section-button")[3]).to have_text "In-house catering"
      within("div#accordion-default-content-4") do
        expect(all("p.govuk-body")[0]).to have_text "Running the service in-house is another option. You may want to consider whether this is right for your school before you procure a contract. There are benefits and challenges to running the service yourself."
      end

      expect(all("span.govuk-accordion__section-button")[4]).to have_text "Starting a procurement process"
      within("div#accordion-default-content-5") do
        expect(all("h3.govuk-heading-m")[0]).to have_text "Who to involve"
      end

      expect(all("span.govuk-accordion__section-button")[5]).to have_text "Writing your requirements"
      within("div#accordion-default-content-6") do
        expect(all("p.govuk-body")[0]).to have_text "This is the document that you give to suppliers explaining what you want to buy, sometimes called a specification."
        expect(all("p.govuk-body")[3]).to have_link("use our tool to create a specification", href: "/")
      end

      expect(all("span.govuk-accordion__section-button")[6]).to have_text "What to do next"
      within("div#accordion-default-content-7") do
        expect(all("p.govuk-body")[0]).to have_text "Once you have your specification, you will need to decide if you will be using the open or restricted procedure."
      end
    end

    expect(find("h2.govuk-heading-m")).to have_text "Where to get help"
    expect(all("p.govuk-body").last).to have_text "See where to get help with buying for schools if you need it."
    expect(all("p.govuk-body").last).to have_link("get help with buying for schools", href: "https://www.gov.uk/guidance/buying-for-schools/get-help-with-buying-for-schools")
  end
end
