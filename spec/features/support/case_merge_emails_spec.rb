RSpec.feature "Merge a New Cases email(s) into an Existing Case", js: true do
  before do
    agent_is_signed_in
    visit "/support/cases/#{from_case.id}"
    click_link "Move emails to existing case"
  end

  let(:agent) { Support::Agent.first }
  let!(:to_case) { Support::CasePresenter.new(create(:support_case, ref: "000001", agent:)) }
  let!(:from_case) { Support::CasePresenter.new(create(:support_case, ref: "000002", agent:)) }
  let(:interaction_to) { to_case.interactions.last }

  it "errors if no case is chosen" do
    click_continue
    expect(find(".govuk-error-summary")).to have_text "You must choose a valid case"
  end

  it "errors if an invalid case ref is given" do
    fill_in "case-autocomplete", with: "a nonsense id"
    find("#case-autocomplete").send_keys :escape
    click_continue
    expect(find(".govuk-error-summary")).to have_text "You must choose a valid case"
  end

  it "errors if the same case is given for merging" do
    fill_in "case-autocomplete", with: from_case.ref
    find("#case-autocomplete").send_keys :escape
    click_continue
    expect(find(".govuk-error-summary")).to have_text "You cannot merge into the same case"
  end

  it "lets the user merge the new case into another" do
    ## SEARCH (step 1)
    fill_in "case-autocomplete", with: to_case.ref
    find("#case-autocomplete").send_keys :down
    find("#case-autocomplete").send_keys :enter

    ## PREVIEW (step 2)
    expect(find("h1")).to have_text "You are moving emails"
    # FROM table
    expect(all("#merge_emails_from td")[0]).to have_text from_case.ref
    expect(all("#merge_emails_from td")[1]).to have_text from_case.organisation_name
    expect(all("#merge_emails_from td")[2]).to have_text from_case.category&.title
    expect(all("#merge_emails_from td")[3]).to have_text from_case.state
    expect(all("#merge_emails_from td")[4]).to have_text from_case.agent&.full_name
    expect(all("#merge_emails_from td")[5]).to have_text from_case.created_at
    # TO table
    expect(all("#merge_emails_to td")[0]).to have_text to_case.ref
    expect(all("#merge_emails_to td")[1]).to have_text to_case.organisation_name
    expect(all("#merge_emails_to td")[2]).to have_text to_case.category&.title
    expect(all("#merge_emails_to td")[3]).to have_text to_case.state
    expect(all("#merge_emails_to td")[4]).to have_text to_case.agent&.full_name
    expect(all("#merge_emails_to td")[5]).to have_text to_case.created_at

    expect(find(".govuk-body-m")).to have_text "Once the emails have been moved, Case #{from_case.ref} will be closed."

    click_continue

    ## SUCCESS (step 3)
    within ".govuk-panel--confirmation" do |_p|
      expect(page).to have_text "Success"
      expect(page).to have_text "The emails have been moved to:"
      expect(page).to have_text "Case #{to_case.ref} - #{to_case.organisation_name}"
      expect(page).to have_text "Assigned to #{to_case.agent_name}"
    end

    expect(find(".govuk-body")).to have_text "Case #{from_case.ref} has been closed."
    expect(find(".govuk-heading-m")).to have_text "Actions"
    expect(all(".govuk-list.govuk-list--bullet li")[0]).to have_link("Go to Case #{to_case.ref}", href: "/support/cases/#{to_case.id}")
    expect(all(".govuk-list.govuk-list--bullet li")[1]).to have_link("Notifications", href: "/support/emails")
    expect(all(".govuk-list.govuk-list--bullet li")[2]).to have_link("My Cases", href: "/support/cases")
  end

  context "when successfully merged", bullet: :skip do
    before do
      ::Support::MergeCaseEmails.new(
        from_case: from_case.__getobj__,
        to_case: to_case.__getobj__,
        agent: ::Support::AgentPresenter.new(agent),
      ).call
    end

    it "records the interaction against the from case" do
      visit "/support/cases/#{from_case.id}#case-history"
      expect(page).to have_text "Status change"
      expect(page).to have_text "From new to closed by first_name last_name on #{Time.zone.now.to_formatted_s(:short)}. Email(s) moved to case ##{to_case.ref}"

      expect(page).to have_text "Email merge"
      expect(page).to have_text "to ##{to_case.ref}"
    end

    it "records the interaction against the to case" do
      visit "/support/cases/#{to_case.id}#case-history"

      expect(page).to have_text "Email merge"
      expect(page).to have_text "from ##{from_case.ref}"
    end
  end
end
