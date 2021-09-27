RSpec.feature "Edit a support request" do
  let(:category) { create(:category) }
  let(:journey) { create(:journey, category: category) }

  let(:support_request) do
    create(:support_request,
           user: journey.user,
           journey: journey,
           category: category,
           phone_number: "0151 000 0000",
           message: "test")
  end

  context "when the user is signed in" do
    before do
      user_is_signed_in(user: journey.user)
      visit "/users/#{journey.user.id}/support-requests/#{support_request.id}"
    end

    specify { expect(page).to have_current_path "/users/#{journey.user.id}/support-requests/#{support_request.id}" }

    it "allows the request to be changed" do
      click_link "edit-phone-number"

      expect(page).to have_current_path "/users/#{journey.user.id}/support-requests/#{support_request.id}/edit?step=1"
      expect(find("label.govuk-label--l")).to have_text "What is your phone number?"

      fill_in "support_form[phone_number]", with: "000 000 0000"
      click_continue

      expect(find("div#flash_notice")).to have_text "Support request updated"
      expect(support_request.reload.phone_number).to eq "000 000 0000"
    end
  end
end
