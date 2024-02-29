require "simplecov"

SimpleCov.collate Dir["coverage/.resultset-*.json"], "rails" do
  project_name "GHBS"
  enable_coverage :branch
  primary_coverage :branch

  formatter SimpleCov::Formatter::HTMLFormatter
  refuse_coverage_drop :line, :branch
  maximum_coverage_drop line: 1, branch: 1
end
