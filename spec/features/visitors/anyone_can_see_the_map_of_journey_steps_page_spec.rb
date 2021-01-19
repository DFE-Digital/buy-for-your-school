feature "Users can see all the steps of a journey" do
  around do |example|
    ClimateControl.modify(
      CONTENTFUL_PLANNING_START_ENTRY_ID: "contentful-starting-step"
    ) do
      example.run
    end
  end

  scenario "Multiple journey steps" do
    stub_get_contentful_entries(
      entry_id: "contentful-starting-step",
      fixture_filename: "closed-path-with-multiple-example.json"
    )

    visit new_journey_map_path

    expect(page).to have_content(I18n.t("journey_map.page_title"))

    within(".govuk-list") do
      list_items = find_all("li")
      within(list_items.first) do
        expect(page).to have_link("When you should start", href: "https://app.contentful.com/spaces/#{ENV["CONTENTFUL_SPACE"]}/environments/#{ENV["CONTENTFUL_ENVIRONMENT"]}/entries/contentful-starting-step")
      end
      within(list_items.last) do
        expect(page).to have_link("Which service do you need?", href: "https://app.contentful.com/spaces/#{ENV["CONTENTFUL_SPACE"]}/environments/#{ENV["CONTENTFUL_ENVIRONMENT"]}/entries/contentful-radio-question")
      end
    end
  end

  context "when the map isn't valid" do
    context "when the same entry is found twice" do
      around do |example|
        ClimateControl.modify(
          CONTENTFUL_PLANNING_START_ENTRY_ID: "contentful-starting-step"
        ) do
          example.run
        end
      end

      it "returns an error message" do
        stub_get_contentful_entries(
          entry_id: "contentful-starting-step",
          fixture_filename: "repeat-entry-example.json"
        )

        visit new_journey_map_path

        expect(page).to have_content(I18n.t("errors.repeat_step_in_the_contentful_journey.page_title"))
        expect(page).to have_content(
          I18n.t("errors.repeat_step_in_the_contentful_journey.page_body", entry_id: "contentful-starting-step")
        )
      end
    end

    context "when the chain becomes obviously too long" do
      around do |example|
        ClimateControl.modify(
          CONTENTFUL_PLANNING_START_ENTRY_ID: "contentful-starting-step"
        ) do
          example.run
        end
      end

      it "returns an error message" do
        stub_const("BuildJourneyOrder::ENTRY_JOURNEY_MAX_LENGTH", 1)
        stub_get_contentful_entries(
          entry_id: "contentful-radio-question",
          fixture_filename: "closed-path-with-multiple-example.json"
        )

        visit new_journey_map_path

        expect(page).to have_content(I18n.t("errors.too_many_steps_in_the_contentful_journey.page_title"))
        expect(page).to have_content(
          I18n.t("errors.too_many_steps_in_the_contentful_journey.page_body", entry_id: "contentful-radio-question", step_count: 1)
        )
      end
    end
  end
end
