RSpec.shared_context "with gias data" do
  # fixture contains 3 schools
  # the "voluntary aided school" is skipped
  # the "closed" school is skipped
  #
  let(:gias_data) { "spec/fixtures/gias/example_schools_data.csv" }
end
