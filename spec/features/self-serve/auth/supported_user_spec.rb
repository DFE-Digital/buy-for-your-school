RSpec.feature "User authentication filter" do
  before do
    user_exists_in_dfe_sign_in(user:)
  end

  context "when the user is not associated with any organisation" do
    let(:user) { build(:user, orgs: nil) }

    before do
      dsi_client = instance_double(::Dsi::Client)
      allow(Dsi::Client).to receive(:new).and_return(dsi_client)
      allow(dsi_client).to receive(:orgs).and_raise(::Dsi::Client::ApiError)
      visit "/"
      click_start
    end

    it "page title" do
      # errors.sign_in.no_organisation.page_title
      expect(page).to have_title "You are not associated with an organisation"
    end

    it "heading" do
      # errors.sign_in.no_organisation.page_title
      expect(find("h1.govuk-heading-l")).to have_text "You are not associated with an organisation"
    end

    it "body" do
      # errors.sign_in.no_organisation.link
      expect(page).to have_link "log into your DfE Sign-In account and select your organisation.",
                                href: "https://test-services.signin.education.gov.uk/request-organisation/search",
                                class: "govuk-link"

      # errors.sign_in.no_organisation.page_body
      body = <<~BODY
        You need to be associated with an organisation before you can use this service. Please log into your DfE Sign-In account and select your organisation.
        This service is available to all state-funded primary, secondary, special and alternative provision schools which have pupils aged between 5-16.
        Private, voluntary-aided and independent early years providers and institutions that provide only for pupils aged 16+ are not eligible for this service.
      BODY
      expect(page).to have_text(body)
    end
  end

  context "when the user is associated with an unsupported organisation" do
    let(:user) { build(:user, :no_supported_schools) }

    before do
      visit "/"
      click_start
    end

    it "page title" do
      # errors.sign_in.unsupported_organisation.page_title
      expect(page).to have_title "Your organisation is not supported by this service"
    end

    it "heading" do
      # errors.sign_in.unsupported_organisation.page_title
      expect(find("h1.govuk-heading-l")).to have_text "Your organisation is not supported by this service"
    end

    it "body" do
      # errors.sign_in.unsupported_organisation.supported_schools
      expect(page).to have_text "This service is for those procuring for a school in England. We can provide support to:"

      # errors.sign_in.unsupported_organisation.supported_schools_list
      within "ul.govuk-list" do
        expect(page).to have_text "a local authority maintained school a federation school an academy in a single or multi-academy trust"
      end

      # errors.sign_in.unsupported_organisation.link
      expect(page).to have_link "sign in to the service again.", href: "/auth/dfe/signout", class: "govuk-link"

      # errors.sign_in.unsupported_organisation.page_body
      body = <<~BODY
        If you want to try a different account you can sign in to the service again.
        This service is available to all state-funded primary, secondary, special and alternative provision schools with pupils aged between 5 to 16 years old.
        Private, voluntary-aided and independent early years providers and institutions with pupils aged 16 years and above are not eligible for this service.
      BODY
      expect(page).to have_text(body)
    end
  end

  context "when the user is a caseworker" do
    around do |example|
      ClimateControl.modify(PROC_OPS_TEAM: "DSI Caseworkers") do
        example.run
      end
    end

    before do
      visit "/"
      click_start
    end

    context "when they new to the service" do
      let(:user) { build(:user, :caseworker) }

      it "takes them to the agent login page" do
        expect(page).to have_title "Supported Buying Case Management"
        expect(page).to have_current_path "/support"
      end
    end

    xcontext "when they have logged in before" do
      let(:user) { create(:user, :caseworker) }

      before do
        create(:support_agent, dsi_uid: user.dfe_sign_in_uid)
      end

      it "takes them to the case management dashboard" do
        expect(page).to have_current_path "/support/cases"
      end
    end
  end

  context "when the user belongs to a group", js: true do
    let(:user) { build(:user, :one_supported_group) }

    before do
      visit "/procurement-support"
      click_on "Start now"
      choose "Yes, use my DfE Sign-in"
      click_continue
    end

    it "takes them to the sign-in confirmation page" do
      expect(page).to have_text "Is this your contact information?"
      expect(page).to have_current_path "/procurement-support/confirm_sign_in"
    end
  end
end
