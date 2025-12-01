RSpec.feature "Content Designers can view" do
  let(:fixture) { "journey-with-multiple-entries" }

  before do
    user_is_signed_in
    # TODO: move JSON file extension for fixtures into the helper method
    stub_contentful_category(fixture_filename: "#{fixture}.json")
    visit "/design/catering"
  end

  context "when it is valid" do
    specify "all the steps in a category" do
      expect(page.title).to have_text "Catering"
      expect(find("h1.govuk-heading-xl")).to have_text "Catering"

      within("ol.govuk-list.govuk-list--number") do
        list_items = find_all("li")

        within(list_items[0]) do
          expect(find("code#liquid_tag")).to have_text "{{ answer_radio-question }}"

          expect(page).to have_link "Which service do you need?",
                                    href: "https://app.contentful.com/spaces/jspwts36h1os/environments/master/entries/radio-question",
                                    class: "govuk-link"
        end

        within(list_items[1]) do
          expect(find("code#liquid_tag")).to have_text "{{ answer_short-text-question }}"

          expect(page).to have_link "What email address did you use?",
                                    href: "https://app.contentful.com/spaces/rwl7tyzv9sys/environments/master/entries/short-text-question",
                                    class: "govuk-link"
        end

        within(list_items[2]) do
          expect(find("code#liquid_tag")).to have_text "{{ answer_long-text-question }}"

          expect(page).to have_link "Describe what you need",
                                    href: "https://app.contentful.com/spaces/rwl7tyzv9sys/environments/develop/entries/long-text-question",
                                    class: "govuk-link"
        end

        within(list_items[3]) do
          expect(find("code#liquid_tag")).to have_text "{{ answer_checkboxes-question }}"

          expect(page).to have_link "Everyday services that are required and need to be considered",
                                    href: "https://app.contentful.com/spaces/rwl7tyzv9sys/environments/develop/entries/checkboxes-question",
                                    class: "govuk-link"
        end
      end
    end
  end

  context "when the map isn't valid" do
    let(:fixture) { "journey-with-repeat-entries" }

    describe "the same entry is found twice" do
      it "returns an error message" do
        # errors.repeat_step_in_the_contentful_journey.page_title
        expect(find("h1.govuk-heading-xl", text: "An unexpected error occurred")).to be_present

        # errors.repeat_step_in_the_contentful_journey.page_body, entry_id: "radio-question"
        message = "One or more steps in the Contentful journey would leave the user in an infinite loop. This entry ID was presented more than once to the user: radio-question"
        expect(find("p.govuk-body", text: message)).to be_present
      end
    end
  end
end
