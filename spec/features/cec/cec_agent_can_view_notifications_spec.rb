require "rails_helper"

describe "Cec agent can view notifications" do
  include_context "with a cec agent"

  it "displays the notifications" do
    support_notification = create(:support_notification, :case_assigned, assigned_to: agent)
    within("#navigation") { click_link "Notifications" }
    expect(page).to have_content("Assigned to case #{support_notification.support_case.ref}")
  end
end
