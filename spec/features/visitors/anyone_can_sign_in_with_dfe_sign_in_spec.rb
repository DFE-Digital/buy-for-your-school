require "rails_helper"

feature "Anyone can sign in with DfE Sign-in" do
  context "when the user exists in the service" do
    scenario "signs in successfully" do
      contentful_category = stub_contentful_category(fixture_filename: "radio-question.json")
      category = persist_category(contentful_category)
      user = create(:user)

      user_exists_in_dfe_sign_in(dsi_uid: user.dfe_sign_in_uid)
      user_starts_the_journey(category.id)

      expect(page).to have_content(I18n.t("specifying.start_page.page_title"))

      within("header") do
        expect(page).to have_content(I18n.t("generic.button.sign_out"))
      end
    end

    scenario "can move between pages without reauthenticating by relying on session data" do
      contentful_category = stub_contentful_category(fixture_filename: "radio-question.json")
      category = persist_category(contentful_category)
      user = create(:user)

      user_exists_in_dfe_sign_in(dsi_uid: user.dfe_sign_in_uid)
      user_starts_the_journey(category.id)
      expect(page).to have_content(I18n.t("specifying.start_page.page_title"))

      # Undo the OmniAuth stub to check we don't require it again
      OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(foo: :bar)

      step = create(:step, :radio)
      journey = step.journey
      journey.update!(user: user)
      visit journey_step_path(journey, step)
      expect(page).to have_content(step.title)
    end
  end

  context "when the user doesn't exist in the service" do
    scenario "new users can sign in" do
      contentful_category = stub_contentful_category(fixture_filename: "radio-question.json")
      category = persist_category(contentful_category)

      a_dsi_uid_we_have_not_seen_before = "7f2cbd01-6779-4524-acc4-0c6ef52120b5"

      # Omit the creation of a fake user to simulate a user not found scenario

      user_exists_in_dfe_sign_in(dsi_uid: a_dsi_uid_we_have_not_seen_before)
      user_starts_the_journey(category.id)

      expect(page).to have_content(I18n.t("specifying.start_page.page_title"))
      new_user = User.find_by(dfe_sign_in_uid: a_dsi_uid_we_have_not_seen_before)
      expect(new_user.dfe_sign_in_uid).to eql(a_dsi_uid_we_have_not_seen_before)
    end
  end

  scenario "sign in fails" do
    user_sign_in_attempt_fails

    expect(Rollbar).to receive(:error).with("Sign in failed unexpectedly").and_call_original

    visit root_path
    click_button I18n.t("generic.button.start")

    expect(page).to have_content(I18n.t("errors.sign_in.unexpected_failure.page_title"))
    expect(page).to have_content(I18n.t("errors.sign_in.unexpected_failure.page_body"))
  end
end
