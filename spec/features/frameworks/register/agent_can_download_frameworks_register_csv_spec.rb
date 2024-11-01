require "rails_helper"

describe "Agent can download frameworks register csv", :js do
  include_context "with a framework evaluation agent"

  before do
    visit frameworks_root_path
  end

  it "has a link to download the CSV of the frameworks data" do
    within "#frameworks-register" do
      expect(page).to have_link "Download Frameworks CSV", class: "govuk-button", href: frameworks_root_path(format: :csv)
    end
  end
end
