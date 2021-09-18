RSpec.feature "Edit an unsubmitted support request" do

  # include_context "with an incomplete journey"

  let(:category) do
    create(:category, title: "Utilities")
  end

  let(:journey) do
    create(:journey, category: category)
  end

  let(:support_request) do
    create(:support_request,
           user: journey.user,
           journey: journey,
           category: category,
           phone_number: "0151 000 0000",
           message: "test")
  end

  before do
    user_is_signed_in(user: journey.user)
    visit "/support-requests/#{support_request.id}"
  end

  specify { expect(page).to have_current_path "/support-requests/#{support_request.id}" }


  describe "step 1" do
    it "updates the phone number" do
      click_link "edit-phone-number"

      expect(page).to have_current_path "/support-requests/#{support_request.id}/edit?step=1"

      expect(find("label.govuk-label--l")).to have_text "What is your phone number?"

      fill_in "support_form[phone_number]", with: "000 000 0000"
      click_continue

      expect(find("div#flash_notice")).to have_text "Support request updated"
      expect(support_request.reload.phone_number).to eq "000 000 0000"
    end
  end

  describe "step 2" do
    it "updates the specification" do
      click_link "edit-specification"

      expect(page).to have_current_path "/support-requests/#{support_request.id}/edit?step=2"

      expect(find("label.govuk-label--l")).to have_text "Which of your specifications are related to this request?"
# binding.pry

      # fill_in "support_form[phone_number]", with: "000 000 0000"
      # click_continue

      # expect(find("div#flash_notice")).to have_text "Support request updated"
      # expect(support_request.reload.journey_id).to eq "000 000 0000"

      expect(page).to have_link "My request is not related to an existing specification", href: "/"
    end
  end
end
