module JourneyHelpers
  def click_first_link_in_task_list
    within("ol.app-task-list") do
      first("a").click
    end
  end

  def start_journey_from_category(category:)
    stub_contentful_category(
      fixture_filename: category
    )

    user_signs_in_and_starts_the_journey
  end

  def start_journey_from_category_and_go_to_question(category:)
    start_journey_from_category(category: category)

    click_first_link_in_task_list
  end
end
