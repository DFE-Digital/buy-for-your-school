feature "Users can see all the steps of a journey" do
  around do |example|
    ClimateControl.modify(
      CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID: "contentful-category-entry"
    ) do
      example.run
    end
  end

  scenario "Multiple journey steps" do
    stub_contentful_category(
      fixture_filename: "journey-with-multiple-entries.json"
    )

    visit new_journey_map_path

    expect(page).to have_content(I18n.t("journey_map.page_title"))

    within(".govuk-list") do
      list_items = find_all("li")
      within(list_items[0]) do
        expect(page)
          .to have_link(
            "Which service do you need?",
            href: "https://app.contentful.com/spaces/#{ENV["CONTENTFUL_SPACE"]}/environments/#{ENV["CONTENTFUL_ENVIRONMENT"]}/entries/radio-question"
          )
      end
      within(list_items[1]) do
        expect(page)
          .to have_link(
            "What email address did you use?",
            href: "https://app.contentful.com/spaces/#{ENV["CONTENTFUL_SPACE"]}/environments/#{ENV["CONTENTFUL_ENVIRONMENT"]}/entries/short-text-question"
          )
      end
      within(list_items[2]) do
        expect(page)
          .to have_link(
            "Describe what you need",
            href: "https://app.contentful.com/spaces/#{ENV["CONTENTFUL_SPACE"]}/environments/#{ENV["CONTENTFUL_ENVIRONMENT"]}/entries/long-text-question"
          )
      end
    end
  end

  context "when the map isn't valid" do
    context "when the same entry is found twice" do
      around do |example|
        ClimateControl.modify(
          CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID: "contentful-category-entry"
        ) do
          example.run
        end
      end

      it "returns an error message" do
        stub_contentful_category(
          fixture_filename: "journey-with-repeat-entries.json",
          stub_steps: false
        )

        visit new_journey_map_path

        expect(page).to have_content(I18n.t("errors.repeat_step_in_the_contentful_journey.page_title"))
        expect(page).to have_content(
          I18n.t("errors.repeat_step_in_the_contentful_journey.page_body", entry_id: "radio-question")
        )
      end
    end
  end
end
