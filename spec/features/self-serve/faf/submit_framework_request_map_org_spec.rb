RSpec.feature "Completed framework requests show org or group name in CM" do
  include_context "with an agent"

  context "when user creates a FaF request for a group" do
    let!(:support_establishment_group) { create(:support_establishment_group, :with_address, name: "Testing Multi Academy Trust", uid: "2314", establishment_group_type: create(:support_establishment_group_type, name: "Multi-academy Trust")) }
    let!(:support_case) { create(:support_case, :opened, organisation: support_establishment_group) }

    before do
      click_button "Agent Login"
      visit "/support/cases/#{support_case.id}#school-details"
    end

    xit "displays the group name in New cases within CM" do
    
      visit "/support/cases#new-cases"
     
      # pp page.source
      expect(page).to have_link "Testing Multi Academy Trust"
    end

    it "displays the group name and type on the case page in CM" do

      pp page.source
      within("#school-details") do
        expect(all("dd.govuk-summary-list__value")[3]).to have_text "Testing Multi Academy Trust"
        expect(all("dd.govuk-summary-list__value")[4]).to have_text "Multi-Academy Trust"
      end
    end
  end

  # def complete_group_step
  #   fill_in "Enter name, Unique group identifier (UID) or UK Provider Reference Number (UKPRN)", with: "Group"
  #   find(".autocomplete__option", text: "Group #1").click
  #   click_continue
  # end

  # def complete_group_confirmation_step
  #   choose "Yes"
  #   click_continue
  # end

  # def complete_name_step
  #   fill_in "framework_support_form[first_name]", with: "Test"
  #   fill_in "framework_support_form[last_name]", with: "User"
  #   click_continue
  # end

  # def complete_email_step
  #   fill_in "framework_support_form[email]", with: "test@email.com"
  #   click_continue
  # end

  def complete_help_message_step
    fill_in "framework_support_form[message_body]", with: "I have a problem"
    click_continue
  end
end