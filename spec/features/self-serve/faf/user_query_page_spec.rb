RSpec.feature "Faf - how can we help?" do
  context "when the user is not signed in" do
    before do
      visit "/procurement-support/new"
    end
  end
end
