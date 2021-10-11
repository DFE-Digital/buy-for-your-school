RSpec.feature "User authentication filter" do
  before do
    user_exists_in_dfe_sign_in(user: user)
    visit "/"
    click_start
  end

  context "when the user is not associated with any organisation" do
    let(:user) { build(:user, orgs: nil) }

    it "page title" do
      # errors.sign_in.no_organisation.page_title
      expect(page.title).to have_text "You are not associated with an organisation"
    end

    it "heading" do
      # errors.sign_in.no_organisation.page_title
      expect(find("h1.govuk-heading-l")).to have_text "You are not associated with an organisation"
    end

    it "body" do
      # errors.sign_in.no_organisation.page_body[1]
      expect(all("p.govuk-body")[0]).to have_text "You need to be associated with an organisation before you can use this service. Please log into your DfE Sign-In account and select your organisation."
      # errors.sign_in.no_organisation.page_body[2]
      expect(all("p.govuk-body")[1]).to have_text "This service is available to all state-funded primary, secondary, special and alternative provision schools which have pupils aged between 5-16."
      # errors.sign_in.no_organisation.page_body[3]
      expect(all("p.govuk-body")[2]).to have_text "Private, voluntary-aided and independent early years providers and institutions that provide only for pupils aged 16+ are not eligible for this service."
    end
  end

  context "when the user is associated with an unsupported organisation" do
    let(:user) { build(:user, :unsupported) }

    it "page title" do
      # errors.sign_in.unsupported_organisation.page_title
      expect(page.title).to have_text "Your organisation is not supported by this service"
    end

    it "heading" do
      # errors.sign_in.unsupported_organisation.page_title
      expect(find("h1.govuk-heading-l")).to have_text "Your organisation is not supported by this service"
    end

    it "body" do
      # errors.sign_in.unsupported_organisation.page_body.supported_schools
      expect(all("p.govuk-body")[0]).to have_text "This service is for those procuring for one school, either:"
      # errors.sign_in.unsupported_organisation.page_body.supported_schools_list[1]
      expect(all("ul.govuk-list.govuk-list--bullet")[0]).to have_text "a local authority maintained school, or"
      # errors.sign_in.unsupported_organisation.page_body.supported_schools_list[2]
      expect(all("ul.govuk-list.govuk-list--bullet")[1]).to have_text "one academy within a single or multi-academy trust"
      # errors.sign_in.unsupported_organisation.page_body.paragraphs[1]
      expect(all("p.govuk-body")[1]).to have_text "If you need to try a different account you can sign in into the service again."
      # errors.sign_in.unsupported_organisation.page_body.paragraphs[2]
      expect(all("p.govuk-body")[2]).to have_text "This service is available to all state-funded primary, secondary, special and alternative provision schools which have pupils aged between 5-16."
      # errors.sign_in.unsupported_organisation.page_body.paragraphs[3]
      expect(all("p.govuk-body")[3]).to have_text "Private, voluntary-aided and independent early years providers and institutions that provide only for pupils aged 16+ are not eligible for this service."
    end
  end

  context "when the user is a caseworker" do
    let(:user) { build(:user, first_name: "Phoebe", last_name: "Buffay") }

    before do
      ENV["PROC_OPS_TEAM"] = "Phoebe Buffay"
    end

    it "takes them to the dashboard" do
      expect(page.title).to have_text "Specifications dashboard"
      expect(page).to have_current_path "/dashboard"
    end
  end
end
