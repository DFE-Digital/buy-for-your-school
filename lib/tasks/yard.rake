if Rails.env.development?
  require "yard"

  YARD::Rake::YardocTask.new do |t|
    t.files   = ["app/**/*.rb", "lib/**/*.rb", "-", "CHANGELOG.md"]
    t.options = ["--plugin", "junk", "--protected", "--private", "--markup", "markdown"]
  end
end
