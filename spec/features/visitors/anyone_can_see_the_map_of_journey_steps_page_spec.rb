feature "Users can see all the steps of a journey" do
  around do |example|
    ClimateControl.modify(
      CONTENTFUL_PLANNING_START_ENTRY_ID: "5kZ9hIFDvNCEhjWs72SFwj"
    ) do
      example.run
    end
  end

  scenario "Multiple journey steps" do
    stub_get_contentful_entries(
      entry_id: "5kZ9hIFDvNCEhjWs72SFwj",
      fixture_filename: "closed-path-with-multiple-example.json"
    )

    visit new_journey_map_path

    within(".govuk-list") do
      list_items = find_all("li")
      expect(list_items.first.text).to have_content("5kZ9hIFDvNCEhjWs72SFwj")
      expect(list_items.last.text).to have_content("hfjJgWRg4xiiiImwVRDtZ")
    end
  end
end
