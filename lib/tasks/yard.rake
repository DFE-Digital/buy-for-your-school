require "yard"

YARD::Rake::YardocTask.new do |t|
  t.files   = ["app/**/*.rb", "-", "CHANGELOG.md"]
  t.options = ["--plugin", "junk", "--protected", "--private", "--markup", "markdown"]
end
