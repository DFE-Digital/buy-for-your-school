RSpec.feature "DfE Sign-in" do
  describe "when successfully authenticated" do
    before do
      contentful_category = stub_contentful_category(fixture_filename: "radio-question.json")
      category = persist_category(contentful_category)
      user_exists_in_dfe_sign_in(user:) # omniauth mock config

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

    context "but their DSI details have changed" do
      let!(:user) { create(:user) }

      let(:updated_user) do
        build(:user,
              dfe_sign_in_uid: user.dfe_sign_in_uid,
              email: user.email,
              first_name: "first_name changed in DSI",
              last_name: "last_name changed in DSI")
      end

      before do
        # force signout
        visit "/auth/failure"
        # change DSI details
        user_exists_in_dfe_sign_in(user: updated_user)
        # DfE sign in
        click_start
        # check new details
        # FIXME: assert changes are visible on /profile
        # visit "/users"
        user.reload
      end

      it "updates the user's names" do
        expect(user.first_name).to eq "first_name changed in DSI"
        expect(user.last_name).to eq "last_name changed in DSI"

        # expect(find("dd.govuk-summary-list__value")[0]).to have_text "first_name changed in DSI last_name changed in DSI"
      end
    end

    context "and the user already exists" do
      let!(:user) { create(:user, first_name: "Generic", last_name: "User", full_name: "Generic User") }

      # generic.button.sign_out
      it "signs in successfully" do
        within("header") do
          expect(page).to have_link "Sign out", href: "/auth/dfe/signout", class: "govuk-header__link"
          expect(page).to have_content "Signed in as Generic User"
        end
      end

      scenario "a user can move between pages without reauthenticating by relying on session data" do
        # Undo the OmniAuth stub to check we don't require it again
        OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(foo: :bar)

        step = create(:step, :radio)
        journey = step.journey
        journey.update!(user:)
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
end
