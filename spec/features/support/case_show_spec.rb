RSpec.feature "Case Management Dashboard - show" do
  let(:state) { "initial" }
  let(:support_case) { create(:support_case, state: state) }

  before do
    user_is_signed_in
    visit "/support/cases/#{support_case.id}"
  end

  it "has 3 visible tabs" do
    expect(all(".govuk-tabs__list-item", visible: true).count).to eq(3)
  end

  it "defaults to the 'School details' tab" do
    expect(find(".govuk-tabs__list-item--selected")).to have_text "School details"
  end

  it "shows School details section" do
    within "#school-details" do
      expect(find(".govuk-summary-list")).to be_visible
    end
  end

  it "School details section contain contact name" do
    within "#school-details" do
      expect(find(".govuk-summary-list")).to have_text "Contact name"
    end
  end

  it "shows the assign link" do
    expect(find("a.assign-owner")).to have_text "Assign to case worker"
  end

  it "shows the resolve link" do
    expect(find("a.resolve")).to have_text "Resolve case"
  end

  context "when the case is open" do
    let(:state) { "open" }

    it "shows the change owner link" do
      expect(find("a.change-owner")).to have_text "Change case owner"
    end

    it "shows the add note link" do
      expect(find("a.add-note")).to have_text "Add a case note"
    end

    it "shows the send email link" do
      expect(find("a.send-email")).to have_text "Send email"
    end

    it "show the log contact link" do
      expect(find("a.log-contact")).to have_text "Log contact with school"
    end
  end

  context "when the case is resolved" do
    let(:state) { "resolved" }

    it "shows the reopen case link" do
      expect(find("a.reopen")).to have_text "Reopen case"
    end
  end
end
