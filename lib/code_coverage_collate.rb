require "simplecov"

SimpleCov.collate Dir["#{ENV['COVERAGE_DIR']}/**/.resultset.json"], "rails" do
  formatter SimpleCov::Formatter::HTMLFormatter
end
