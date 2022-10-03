RSpec.feature "Editing a 'Digital Support' request" do
  let(:category) { create(:category, title: "Utilities") }
  let(:user) { create(:user) }
  let(:journey) { create(:journey, category:, user:) }
  let(:answers) { find_all("dd.govuk-summary-list__value") }

  before do
    # TODO: use `title` and remove `travel_to` used to control `created_at`
    travel_to Time.zone.local(2021, 9, 1, 0o1, 0o4, 44)
    user_is_signed_in(user: journey.user)
    visit "/support-requests/#{support_request.id}"
  end

  xdescribe "step 1: adding a phone number" do
    let(:support_request) do
      create(:support_request,
             user: journey.user,
             journey:,
             category: nil,
             phone_number: "invalid phone number",
             message_body: "",
             school_urn: "123")
    end

    it "adds a valid phone number" do
      click_link "edit-phone-number"

      expect(page).to have_current_path "/support-requests/#{support_request.id}/edit?step=1"

      expect(find("label.govuk-label--l")).to have_text "What is your phone number?"

      fill_in "support_form[phone_number]", with: "01234567890"
      click_continue

      expect(find("div#flash_notice")).to have_text "Support request updated"
      expect(page).to have_current_path "/support-requests/#{support_request.id}"
      expect(answers[2]).to have_text "01234567890"
    end

    it "rejects an invalid phone number" do
      click_link "edit-phone-number"

      expect(page).to have_current_path "/support-requests/#{support_request.id}/edit?step=1"

      expect(find("label.govuk-label--l")).to have_text "What is your phone number?"

      fill_in "support_form[phone_number]", with: "not a valid number"
      click_continue

      expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
    end
  end

  describe "step 2: choosing a school" do
    let(:support_request) do
      create(:support_request,
             user: journey.user,
             journey:,
             category: nil,
             phone_number: nil,
             message_body: "",
             school_urn: nil)
    end

    context "when user has selected a school" do
      let(:user) { create(:user, :one_supported_school) }

      let(:support_request) do
        create(:support_request,
               user: journey.user,
               journey:,
               category: nil,
               phone_number: nil,
               message_body: "",
               school_urn: "100253")
      end

      it "shows the school name" do
        within "#support-request-school" do
          expect(page).to have_text "Specialist School for Testing"
        end
      end
    end

    it "allows editing of the school" do
      click_link "edit-school"

      expect(page).to have_current_path "/support-requests/#{support_request.id}/edit?step=2"
    end

    describe "editing the school" do
      context "when user has multiple supported schools" do
        let(:user) { create(:user, :many_supported_schools) }

        it "allows the user to choose a different school" do
          click_link "edit-school"

          choose "Greendale Academy for Bright Sparks"

          click_continue

          expect(support_request.reload.school_urn).to eq "100254"
        end
      end
    end
  end

  describe "step 3: a specification" do
    context "when choosing one" do
      let(:support_request) do
        create(:support_request,
               user: journey.user,
               journey: nil,
               category:,
               phone_number: nil,
               message_body: nil,
               school_urn: "123")
      end

      it "updates the specification" do
        click_link "edit-specification"

        expect(page).to have_current_path "/support-requests/#{support_request.id}/edit?step=3"

        expect(find("legend.govuk-fieldset__legend--l")).to have_text "Which specification is this related to?"

        choose "1 September 2021"
        click_continue

        expect(find("div#flash_notice")).to have_text "Support request updated"
        expect(page).to have_current_path "/support-requests/#{support_request.id}"

        # journey attached
        expect(support_request.reload.journey_id).not_to be_nil
        expect(answers[3]).to have_text "1 September 2021"

        # category is forgotten
        expect(support_request.reload.category_id).to be_nil

        # inferred from the journey
        expect(support_request.reload.journey.category.title).to eq "Utilities"
        expect(answers[4]).to have_text "Utilities"
      end
    end

    context "when NOT choosing one" do
      let(:support_request) do
        create(:support_request,
               user: journey.user,
               journey: nil,
               category: nil,
               phone_number: nil,
               message_body: nil,
               school_urn: "123")
      end

      it "requires a category to be chosen" do
        click_link "edit-specification"

        expect(page).to have_current_path "/support-requests/#{support_request.id}/edit?step=3"

        expect(find("legend.govuk-fieldset__legend--l")).to have_text "Which specification is this related to?"

        choose "My request is not related to an existing specification"
        click_continue

        # advance to step 3
        expect(page).to have_current_path "/support-requests/#{support_request.id}"
        expect(find("legend.govuk-fieldset__legend--l")).to have_text "What are you buying?"

        choose "Utilities"
        click_continue

        expect(find("div#flash_notice")).to have_text "Support request updated"
        expect(page).to have_current_path "/support-requests/#{support_request.id}"

        # journey not added
        expect(support_request.reload.journey_id).to be_nil

        # category added
        expect(support_request.reload.category.title).to eq "Utilities"
        expect(answers[4]).to have_text "Utilities"
      end
    end
  end

  describe "step 4: choosing a category" do
    let(:support_request) do
      create(:support_request,
             user: journey.user,
             journey:,
             category: nil,
             phone_number: nil,
             message_body: nil,
             school_urn: "123")
    end

    it "updates the category" do
      click_link "edit-category"

      expect(page).to have_current_path "/support-requests/#{support_request.id}/edit?step=4"

      expect(find("legend.govuk-fieldset__legend--l")).to have_text "What are you buying?"

      choose "Utilities"
      click_continue

      expect(find("div#flash_notice")).to have_text "Support request updated"
      expect(page).to have_current_path "/support-requests/#{support_request.id}"

      # category is attached
      expect(support_request.reload.category.title).to eq "Utilities"
      expect(support_request.reload.category_id).not_to be_nil
      expect(answers[4]).to have_text "Utilities"

      # journey is forgotten
      expect(support_request.reload.journey_id).to be_nil
    end
  end

  describe "step 5: writing a message" do
    let(:support_request) do
      create(:support_request,
             user: journey.user,
             journey:,
             category: nil,
             phone_number: nil,
             message_body: nil,
             school_urn: "123")
    end

    it "adds a message" do
      click_link "edit-message"

      expect(page).to have_current_path "/support-requests/#{support_request.id}/edit?step=5"

      expect(find("label.govuk-label--l")).to have_text "How can we help?"

      fill_in "support_form[message_body]", with: "I need help"
      click_continue

      expect(find("div#flash_notice")).to have_text "Support request updated"
      expect(page).to have_current_path "/support-requests/#{support_request.id}"

      # message is added
      expect(answers[5]).to have_text "I need help"
      expect(support_request.reload.message_body).to eql "I need help"
    end
  end

  describe "step 6: providing the procurement amount", js: true do
    let(:support_request) do
      create(:support_request,
             user: journey.user,
             journey:,
             category: nil,
             phone_number: nil,
             school_urn: "123")
    end

    context "when procurement amount is known" do
      before do
        click_link "edit-procurement-amount"
        fill_in "support_form[procurement_amount]", with: "56.24"
        click_continue
      end

      it "updates the procurement amount" do
        expect(answers[6]).to have_text "£56.24"
        expect(support_request.reload.procurement_amount).to eq 56.24
      end
    end

    context "when procurement amount is unknown" do
      before do
        click_link "edit-procurement-amount"
        fill_in "support_form[procurement_amount]", with: nil
        click_continue
      end

      it "removes the procurement amount" do
        expect(answers[6]).to have_text "Not known"
        expect(support_request.reload.procurement_amount).to be_nil
      end
    end
  end

  describe "step 7: setting the confidence level" do
    let(:support_request) do
      create(:support_request,
             user: journey.user,
             journey:,
             category: nil,
             phone_number: nil,
             school_urn: "123")
    end

    before do
      click_link "edit-confidence-level"
      choose "Not applicable"
      click_continue
    end

    it "updates the confidence level" do
      expect(answers[7]).to have_text "Not applicable"
      expect(support_request.reload.confidence_level).to eq "not_applicable"
    end
  end

  describe "step 8: providing special requirements", js: true do
    let(:support_request) do
      create(:support_request,
             user: journey.user,
             journey:,
             category: nil,
             phone_number: nil,
             school_urn: "123")
    end

    context "when there are special requirements" do
      before do
        click_link "edit-special-requirements"
        choose "Yes"
        fill_in "support_form[special_requirements]", with: "Updated special requirements"
        click_continue
      end

      it "updates the special requirements" do
        expect(answers[8]).to have_text "Updated special requirements"
        expect(support_request.reload.special_requirements).to eq "Updated special requirements"
      end
    end

    context "when there are no special requirements" do
      before do
        click_link "edit-special-requirements"
        choose "No"
        click_continue
      end

      it "updates the special requirements" do
        expect(answers[8]).to have_text "-"
        expect(support_request.reload.special_requirements).to eq ""
      end
    end
  end
end
