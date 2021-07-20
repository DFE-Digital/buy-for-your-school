#
# Convenience navigation methods
# TODO: remove stubbing/fixtures
module JourneyHelpers
  def click_create_spec_link
    click_on "Create a new specification"
  end

  def click_first_link_in_section_list
    within("ol.app-task-list.sections") do
      first("a").click
    end
  end

  def click_first_link_in_task_list
    within("ol.app-task-list.tasks") do
      first("a").click
    end
  end

  # TODO: remove stub_contentful_category in favour of shared setup using factories
  def start_journey_from_category(category: "replace this with fixture.json")
    contentful_category = stub_contentful_category(fixture_filename: category)

    category = persist_category(contentful_category)

    user_signs_in_and_starts_the_journey(category.id)
  end

  def start_journey_from_category_and_go_to_first_section(category:)
    start_journey_from_category(category: category)
    click_first_link_in_section_list
  end

  def persist_category(contentful_category)
    create(:category,
           title: contentful_category.title,
           description: contentful_category.description,
           liquid_template: contentful_category.combined_specification_template,
           contentful_id: contentful_category.id)
  end
end
