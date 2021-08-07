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
