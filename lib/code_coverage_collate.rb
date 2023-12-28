require "simplecov"

SimpleCov.collate Dir["coverage/.resultset-*.json"], "rails" do
  project_name "GHBS"
  enable_coverage :branch
  primary_coverage :branch

  formatter SimpleCov::Formatter::HTMLFormatter
end
