require "rails_helper"

describe "MAT flow (option 2)", :js do
  include_context "with schools and groups"

  before do
    create(:support_category, title: "DfE Energy for Schools service")
  end

  specify "Authenticating and seeing the school selection" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    # No Support::Case, Energy::OnboardingCase
    expect(Support::Case.count).to eq(0)
    expect(Energy::OnboardingCase.count).to eq(0)
    expect(Energy::OnboardingCaseOrganisation.count).to eq(0)

    visit energy_school_selection_path

    # See the school picker including the MAT
    expect(page).to have_text("Which school are you buying for?")
    expect(page).to have_text("Testing Multi Academy Trust")
    choose "Testing Multi Academy Trust"
    click_button "Continue"

    # The Support::Case and Energy::OnboardingCase should be created
    expect(Support::Case.count).to eq(1)
    expect(Energy::OnboardingCase.count).to eq(1)
    expect(Energy::OnboardingCaseOrganisation.count).to eq(0)

    #  See the MAT school picker
    expect(page).to have_text("Which schools in your academy trust")
    check "Greendale Academy for Bright Sparks" #  FIXME: This sh be choose
    click_button "Continue"

    # The Energy::OnboardingCaseOrganisation should be created
    sleep 1
    expect(Support::Case.count).to eq(1)
    expect(Energy::OnboardingCase.count).to eq(1)
    expect(Energy::OnboardingCaseOrganisation.count).to eq(1)

    # The Energy::Org should belong to a MAT BUT still be a school
    school = Energy::OnboardingCaseOrganisation.first
    expect(school.onboardable_type).to eq("Support::Organisation")
    expect(school.onboardable.name).to eq("Greendale Academy for Bright Sparks")

    # See auth page for chosen school
    expect(page).to have_text("Are you authorised")
    expect(page).to have_text("Testing Multi Academy Trust")
    expect(page).to have_text("Greendale Academy for Bright Sparks")
    click_link "Continue"

    # See energy type selection page
    expect(page).to have_text("What type of E")
  end
end
