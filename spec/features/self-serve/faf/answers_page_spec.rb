RSpec.feature "'Find a Framework' answers" do
  let(:keys) { all("dt.govuk-summary-list__key") }
  let(:values) { all("dd.govuk-summary-list__value") }
  let(:actions) { all("dd.govuk-summary-list__actions") }

  context "when completed as an authenticated user" do
    let(:request) do
      create(:framework_request, user: user, school_urn: "100254", group_uid: nil)
    end

    let(:user) do
      create(:user, :many_supported_schools_and_groups,
             first_name: "Generic",
             last_name: "User")
    end

    let(:establishment_type) do
      create(:support_establishment_type, name: "Community school")
    end

    before do
      create(:support_organisation, :with_address,
             urn: "100254",
             name: "Greendale Academy for Bright Sparks",
             phase: 7,
             number: "334",
             ukprn: "4346",
             establishment_type: establishment_type)

      user_is_signed_in(user: user)
      visit "/procurement-support/#{request.id}"
    end

    it "goes back to the message page" do
      click_on "Back"
      expect(page).to have_current_path "/procurement-support/#{request.id}/edit?step=7"
      expect(page).to have_text "How can we help?"
    end

    it "has submission information" do
      expect(find("h1.govuk-heading-l")).to have_text "Send your request"
      expect(find("p.govuk-body")).to have_text "Once you send this request, we will review it and get in touch within 2 working days."
      expect(page).to have_button "Send request"
    end

    it "only allows some fields to be edited" do
      within("dl.govuk-summary-list") do
        expect(keys[0]).to have_text "Your name"
        expect(values[0]).to have_text "Generic User"
        expect(actions[0]).not_to have_link "Change"

        expect(keys[1]).to have_text "Your email address"
        expect(values[1]).to have_text "test@test"
        expect(actions[1]).not_to have_link "Change"

        expect(keys[2]).to have_text "Your school"
        expect(values[2]).to have_text "Greendale Academy for Bright Sparks"
        expect(actions[2]).to have_link "Change"

        expect(keys[3]).to have_text "School type"
        expect(values[3]).to have_text "Single"
        expect(actions[3]).not_to have_link "Change"

        expect(keys[4]).to have_text "Description of request"
        expect(values[4]).to have_text "please help!"
        expect(actions[4]).to have_link "Change"
      end
    end
  end

  context "when completed as a guest" do
    let(:request) do
      create(:framework_request, school_urn: nil, group_uid: "9876")
    end

    let(:group_type) do
      create(:support_establishment_group_type, name: "Multi-academy Trust")
    end

    before do
      create(:support_establishment_group, :with_address,
             name: "Group #1",
             uid: "9876",
             establishment_group_type: group_type)

      visit "/procurement-support/#{request.id}"
    end

    it "goes back to the message page" do
      click_on "Back"
      expect(page).to have_current_path "/procurement-support/#{request.id}/edit?step=7"
      expect(page).to have_text "How can we help?"
    end

    it "has submission information" do
      expect(find("h1.govuk-heading-l")).to have_text "Send your request"
      expect(find("p.govuk-body")).to have_text "Once you send this request, we will review it and get in touch within 2 working days."
      expect(page).to have_button "Send request"
    end

    it "allows all fields to be edited" do
      within("dl.govuk-summary-list") do
        expect(all("dt.govuk-summary-list__key")[0]).to have_text "Your name"
        expect(values[0]).to have_text "David Georgiou"
        expect(actions[0]).to have_link "Change"

        expect(all("dt.govuk-summary-list__key")[1]).to have_text "Your email address"
        expect(values[1]).to have_text "email@example.com"
        expect(actions[1]).to have_link "Change"

        expect(all("dt.govuk-summary-list__key")[2]).to have_text "Your school"
        expect(values[2]).to have_text "Group #1"
        expect(actions[2]).to have_link "Change"

        expect(all("dt.govuk-summary-list__key")[3]).to have_text "School type"
        expect(values[3]).to have_text "Multi-academy Trust"
        expect(actions[3]).to have_link "Change"

        expect(all("dt.govuk-summary-list__key")[4]).to have_text "Description of request"
        expect(values[4]).to have_text "please help!"
        expect(actions[4]).to have_link "Change"
      end
    end
  end
end
