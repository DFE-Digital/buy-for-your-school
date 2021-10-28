RSpec.feature "User authentication filter" do
  before do
    user_exists_in_dfe_sign_in(user: user)
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
      expect(page).to have_link "log into your DfE Sign-In account and select your organisation.", href: "https://test-services.signin.education.gov.uk/request-organisation/search", class: "govuk-link"

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
    let(:user) { build(:user, :unsupported) }

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
      expect(page).to have_text "This service is for those procuring for one school, either:"

      # errors.sign_in.unsupported_organisation.supported_schools_list
      within "ul.govuk-list" do
        expect(page).to have_text "a local authority maintained school, or one academy within a single or multi-academy trust"
      end

      # errors.sign_in.unsupported_organisation.link
      expect(page).to have_link "sign in into the service again.", href: "/auth/dfe/signout", class: "govuk-link"

      # errors.sign_in.unsupported_organisation.page_body
      body = <<~BODY
        If you need to try a different account you can sign in into the service again.
        This service is available to all state-funded primary, secondary, special and alternative provision schools which have pupils aged between 5-16.
        Private, voluntary-aided and independent early years providers and institutions that provide only for pupils aged 16+ are not eligible for this service.
      BODY
      expect(page).to have_text(body)
    end
  end

  context "when the user is a caseworker" do
    let(:user) { build(:user, :caseworker) }

    around do |example|
      ClimateControl.modify(PROC_OPS_TEAM: "DSI Caseworkers") do
        example.run
      end
    end

    before do
      visit "/"
      click_start
    end

    it "takes them to the dashboard" do
      expect(page).to have_title "Specifications dashboard"
      expect(page).to have_current_path "/dashboard"
    end
  end
end
