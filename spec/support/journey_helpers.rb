#
# Convenience navigation methods
# TODO: remove stubbing/fixtures
module JourneyHelpers
  # generic.button.start
  def click_start
    click_button "Start now"
  end

  # generic.button.next
  def click_continue
    click_on "Continue"
  rescue Capybara::ElementNotFound
    click_on "Yes, continue"
  end

  # generic.button.update
  def click_update
    click_on "Update"
  end

  # generic.button.back
  def click_back
    click_on "Back"
  end

  def click_breadcrumb(breadcrumb)
    within(".govuk-breadcrumbs") do
      click_on breadcrumb
    end
  end

  # dashboard.create.button
  def click_create
    click_on "Create a new specification"
  end

  # journey.specification.button
  def click_view
    click_on "View your specification"
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

  # expects journey
  def visit_journey
    visit journey_path(journey.id)
  end

  def user_signs_in_and_starts_the_journey(category_slug)
    user_exists_in_dfe_sign_in # sign_in_helpers
    visit "/"
    click_start
    click_create
    find("#new-journey-form-category-#{category_slug}-field").click
    click_continue
    fill_in "new_journey_form[name]", with: "New specification"
    click_continue
  end

  # TODO: remove stub_contentful_category in favour of shared setup using factories
  def start_journey_from_category(category: "replace this with fixture.json")
    contentful_category = stub_contentful_category(fixture_filename: category)

    category = persist_category(contentful_category)

    user_signs_in_and_starts_the_journey(category.slug)
  end

  def persist_category(contentful_category)
    create(:category,
           title: contentful_category.title,
           description: contentful_category.description,
           liquid_template: contentful_category.combined_specification_template,
           contentful_id: contentful_category.id,
           slug: contentful_category.slug)
  end
end
