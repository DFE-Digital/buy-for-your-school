module JourneyHelpers
  def click_first_link_in_task_list
    within("ol.app-task-list") do
      first("a").click
    end
  end

  def start_journey_from_category_and_go_to_question(category:)
    stub_contentful_category(
      fixture_filename: category
    )

    visit root_path

    click_on(I18n.t("generic.button.start"))

    click_first_link_in_task_list
  end
end
