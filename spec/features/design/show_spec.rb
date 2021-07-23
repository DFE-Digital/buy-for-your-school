RSpec.feature "Content Designers can view" do
  let(:fixture) { "journey-with-multiple-entries" }

  before do
    user_is_signed_in
    stub_contentful_category(fixture_filename: "#{fixture}.json")
    visit "/design/catering"
  end

  context "when it is valid" do
    specify "all the steps in a category" do
      # design.page_title
      expect(page.title).to have_text "Template Designer"
      expect(find("h1.govuk-heading-xl")).to have_text "Template Designer"

      within("ol.govuk-list.govuk-list--number") do
        list_items = find_all("li")

        within(list_items[0]) do
          expect(find("b")).to have_text "Which service do you need?"

          # step_id internal tag
          expect(find("code")).to have_text "{{ answer_radio-question }}"

          # design.edit_step_link_text
          expect(page).to have_link "Edit step in Contentful",
                                    href: "https://app.contentful.com/spaces/test/environments/master/entries/radio-question",
                                    class: "govuk-link"

          # design.preview_step_link_text
          expect(page).to have_link "Preview step in service", href: "/preview/entries/radio-question", class: "govuk-link"
        end

        within(list_items[1]) do
          expect(find("b")).to have_text "What email address did you use?"

          # step_id internal tag
          expect(find("code")).to have_text "{{ answer_short-text-question }}"

          # design.edit_step_link_text
          expect(page).to have_link "Edit step in Contentful",
                                    href: "https://app.contentful.com/spaces/test/environments/master/entries/short-text-question",
                                    class: "govuk-link"

          # design.preview_step_link_text
          expect(page).to have_link "Preview step in service", href: "/preview/entries/short-text-question", class: "govuk-link"
        end

        within(list_items[2]) do
          expect(find("b")).to have_text "Describe what you need"

          # step_id internal tag
          expect(find("code")).to have_text "{{ answer_long-text-question }}"

          # design.edit_step_link_text
          expect(page).to have_link "Edit step in Contentful",
                                    href: "https://app.contentful.com/spaces/test/environments/master/entries/long-text-question",
                                    class: "govuk-link"

          # design.preview_step_link_text
          expect(page).to have_link "Preview step in service", href: "/preview/entries/long-text-question", class: "govuk-link"
        end
      end
    end
  end

  context "when the map isn't valid" do
    let(:fixture) { "journey-with-repeat-entries" }

    describe "the same entry is found twice" do
      it "returns an error message" do
        # errors.repeat_step_in_the_contentful_journey.page_title
        expect(find("h1.govuk-heading-xl")).to have_text "An unexpected error occurred"

        # errors.repeat_step_in_the_contentful_journey.page_body, entry_id: "radio-question"
        expect(find("p.govuk-body")).to have_text <<~DUPLICATE.chomp
          One or more steps in the Contentful journey would leave the user in an infinite loop. This entry ID was presented more than once to the user: radio-question
        DUPLICATE
      end
    end
  end
end
