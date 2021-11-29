require "rspec/expectations"

UUID_REGEXP = /([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/

# allowed:
#   /journeys/<UUID>
#   /journeys/<UUID>/
#
# disallowed:
#   /journeys/<UUID>/x
#
RSpec::Matchers.define :have_a_journey_path do
  match do |page|
    page.current_path.match? %r{^/journeys/#{UUID_REGEXP}/?(?!.+)}
  end
end

# allowed:
#   /journeys/<UUID>/tasks/<UUID>
#   /journeys/<UUID>/tasks/<UUID>/
#
# disallowed:
#   /journeys/<UUID>/tasks/<UUID>/x
#
RSpec::Matchers.define :have_a_task_path do
  match do |page|
    page.current_path.match? %r{^/journeys/#{UUID_REGEXP}/tasks/#{UUID_REGEXP}/?(?!.+)}
  end
end

# allowed:
#   /journeys/<UUID>/steps/<UUID>
#   /journeys/<UUID>/steps/<UUID>/
#
# disallowed:
#   /journeys/<UUID>/steps/<UUID>/x
#
RSpec::Matchers.define :have_a_step_path do
  match do |page|
    page.current_path.match? %r{^/journeys/#{UUID_REGEXP}/steps/#{UUID_REGEXP}/?(?!.+)}
  end
end

# allowed:
#   /journeys/<UUID>/steps/<UUID>/answers
#   /journeys/<UUID>/steps/<UUID>/answers/
#
# disallowed:
#   /journeys/<UUID>/steps/<UUID>/answers/x
#
RSpec::Matchers.define :have_an_answer_path do
  match do |page|
    page.current_path.match? %r{^/journeys/#{UUID_REGEXP}/steps/#{UUID_REGEXP}/answers/?(?!.+)}
  end
end

# allowed:
#   /journeys/<UUID>/steps/<UUID>/edit
#   /journeys/<UUID>/steps/<UUID>/edit/
#
# disallowed:
#   /journeys/<UUID>/steps/<UUID>/edit/x
#
RSpec::Matchers.define :have_an_edit_step_path do
  match do |page|
    page.current_path.match? %r{^/journeys/#{UUID_REGEXP}/steps/#{UUID_REGEXP}/edit/?(?!.+)}
  end
end

# allowed:
#   /support/cases/<UUID>
#   /support/cases/<UUID>/
#
# disallowed:
#   /support/cases/<UUID>/x
#
RSpec::Matchers.define :have_a_support_case_path do
  match do |page|
    page.current_path.match? %r{^/support/cases/#{UUID_REGEXP}/?(?!.+)}
  end
end

RSpec::Matchers.define :have_breadcrumbs do |input|
  match do |page|
    page.all("li.govuk-breadcrumbs__list-item").collect(&:text) == input
  end
end

RSpec::Matchers.define :have_link_to_open_in_new_tab do |locator, options = {}|
  match do |page|
    link = page.find_link(locator, **options)
    link.present? && link[:target] == "_blank"
  end
end

RSpec::Matchers.define :be_categorised do |expected|
  match do |actual|
    actual&.keys&.first == expected[:parent] && actual&.values&.first&.keys&.first == expected[:child]
  end

  failure_message do |actual|
    "expected that #{actual} would have parent #{expected[:parent]} and child #{expected[:child]}"
  end
end
