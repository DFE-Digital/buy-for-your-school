#
# Convenience navigation methods
# TODO: remove stubbing/fixtures
module JourneyHelpers
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
end
