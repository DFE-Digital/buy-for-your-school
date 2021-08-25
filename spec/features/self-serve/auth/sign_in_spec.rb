RSpec.feature "DfE Sign-in" do
  describe "when successfully authenticated" do
    before do
      contentful_category = stub_contentful_category(fixture_filename: "radio-question.json")
      category = persist_category(contentful_category)
      user_exists_in_dfe_sign_in(user: user) # omniauth mock config

      # landing page
      visit "/"
      # DfE sign in
      click_start
      # new journey
      click_create
      # choose category
      find("label", text: category.title).click
      # begin
      click_continue
    end

    context "and the user already exists" do
      let!(:user) { create(:user) }

      # generic.button.sign_out
      it "signs in successfully" do
        within("header") do
          expect(page).to have_link "Sign out", href: "/auth/dfe/signout", class: "govuk-header__link"
        end
      end

      scenario "a user can move between pages without reauthenticating by relying on session data" do
        # Undo the OmniAuth stub to check we don't require it again
        OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(foo: :bar)

        step = create(:step, :radio)
        journey = step.journey
        journey.update!(user: user)
        visit journey_step_path(journey, step)
        expect(page).to have_content(step.title)
      end
    end

    context "and the user is new to the service" do
      let(:user) do
        build(:user, dfe_sign_in_uid: "7f2cbd01-6779-4524-acc4-0c6ef52120b5")
      end

      scenario "a new account is created" do
        expect(User.find_by(dfe_sign_in_uid: user.dfe_sign_in_uid)).not_to be_nil
      end
    end
  end

  context "when authentication fails" do
    before do
      OmniAuth.config.mock_auth[:dfe] = :invalid_credentials
    end

    it "redirects to the homepage and issues a flash message" do
      expect(Rollbar).to receive(:error).with(
        "Sign in failed unexpectedly",
        dfe_sign_in_uid: anything,
      ).and_call_original

      visit "/"
      click_start

      expect(page).to have_current_path "/"
      expect(page.driver.request.session.keys).to be_empty
      expect(find("h3.govuk-notification-banner__heading")).to have_text "Sign in failed unexpectedly, please try again."

      # If the session cannot be cleared
      # errors.sign_in.unexpected_failure.page_title
      # expect(find("h1.govuk-heading-xl")).to have_text "An unexpected error occurred"
      # errors.sign_in.unexpected_failure.page_body
      # expect(find("p.govuk-body")).to have_text "The service was unable to successfully authenticate you. The team have been notified of this problem and you should be able to retry shortly."
    end
  end
end
