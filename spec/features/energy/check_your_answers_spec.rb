require "rails_helper"

describe "'Check your answers' flows", :js do
  include_context "with energy suppliers"

  before do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    case_organisation.update!(gas_single_multi: gas_single_multi)

    gas_meter_numbers.each do |mprn|
      create(:energy_gas_meter, :with_valid_data, mprn: mprn, onboarding_case_organisation: case_organisation)
    end

    # Visit Check page
    visit energy_case_check_your_answers_path(onboarding_case)
  end

  let(:gas_single_multi) { "single" }
  let(:gas_meter_numbers) { %w[654321] }

  describe "Gas contract" do
    specify "Clicking 'Change'" do
      expect(page).to have_text("Gas contract")
      find("#gas_contract_information_change").click # `click_button "Change"` results in: Unable to find button "Change" that is not disabled

      # Land on Gas Contract
      expect(page).to have_text("Gas Contract")
      expect(page).not_to have_button("Save and go to tasks")
      choose "Other"
      fill_in "Gas supplier", with: "Great Gas Ltd"
      click_button "Save and continue"

      # Back to Check page
      expect(page).to have_text("Check your answers")
      expect(page).to have_text("Great Gas Ltd")
    end
  end

  describe "Electricity contract" do
    specify "Clicking 'Change'" do
      expect(page).to have_text("Electricity contract")
      find("#electric_contract_information_change").click

      # Land on Electricity Contract
      expect(page).to have_text("Electricity Contract")
      expect(page).not_to have_button("Save and go to tasks")
      choose "Other"
      fill_in "Electricity supplier", with: "Emilys Leccie Co"
      click_button "Save and continue"

      # Back to Check page
      expect(page).to have_text("Check your answers")
      expect(page).to have_text("Emilys Leccie Co")
    end
  end

  describe "Gas meters and usage" do
    let(:new_mprn) { "923457" }

    context "Single meter has been specified" do
      before do
        expect(page).to have_text("Gas information")
        find("#gas_meters_and_usage_change").click

        # Land on single or multi meter screen
        expect(page).to have_text("Is this a single or multi meter site?")
        expect(page).not_to have_button("Save and go to tasks")
      end
      context "Stay with single meter" do
        specify "Clicking 'Change'" do
          choose "Single meter"
          click_button "Save and continue"

          # Land on the edit screen for the single meter
          expect(page).to have_text("Gas meter details")
          expect(page).not_to have_button("Save and go to tasks")
          expect(page).to have_field("Add a Meter Point Reference Number (MPRN)", with: gas_meter_numbers.first)
          fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "1234"
          click_button "Save and continue"

          # Land back on Check page
          expect(page).to have_text("Check your answers")
        end
      end
      context "Change to multi meter" do
        specify "Clicking 'Change'" do
          choose "Multi meter"
          click_button "Save and continue"

          # Land on the new screen for the single meter
          expect(page).to have_text("Gas meter details")
          expect(page).not_to have_button("Save and go to tasks")
          fill_in "Add a Meter Point Reference Number (MPRN)", with: new_mprn
          fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "1234"
          click_button "Save and continue"

          # Land on meter list
          expect(page).to have_text("MPRN summary")
          expect(page).not_to have_button("Save and go to tasks")
          find("#save_and_continue").click

          # Land on consolidation screen
          expect(page).to have_text("Do you want your MPRNs consolidated on one bill?")
          expect(page).not_to have_button("Save and go to tasks")
          choose "No, I want a separate bill for each MPRN"
          click_button "Save and continue"

          # Back to Check page
          expect(page).to have_text("Check your answers")
          expect(page).to have_text(new_mprn)
        end
      end
    end

    context "Multi meter has been specified" do
      let(:gas_single_multi) { "multi" }
      let(:gas_meter_numbers) { %w[654321 765432] }

      specify "Clicking 'Change'" do
        expect(page).to have_text("Gas information")
        find("#gas_meters_and_usage_change").click

        # Land on gas meter list
        expect(page).to have_text("MPRN summary")
        expect(page).not_to have_button("Save and go to tasks")

        # Add a meter
        find("#add_another_mprn").click # click_button "Add another MPRN" results in: Unable to find button "Add another MPRN" that is not disabled
        # Land on Gas meter details
        expect(page).to have_text("Gas meter details")
        expect(page).not_to have_button("Save and go to tasks")
        fill_in "Add a Meter Point Reference Number (MPRN)", with: new_mprn
        fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "123"
        click_button "Save and continue"
        # Back on meter list
        expect(page).to have_text("MPRN summary")

        # Delete a meter
        within "table > tbody > tr:nth-child(1)" do
          find(".remove_meter").click
        end
        # Land on confirm screen
        expect(page).to have_text("Are you sure you want to remove this MPRN?")
        find(".remove_meter").click
        # Back on meter list
        expect(page).to have_text("MPRN summary")

        # Change a meter
        within "table > tbody > tr:nth-child(1)" do
          click_link "Change"
        end
        # Land on edit page
        expect(page).to have_text("Gas meter details")
        fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "5432"
        click_button "Save and continue"
        # Back on meter list
        expect(page).to have_text("MPRN summary")
        find("#save_and_continue").click

        # Land on consolidation screen
        expect(page).to have_text("Do you want your MPRNs consolidated on one bill?")
        expect(page).not_to have_button("Save and go to tasks")
        choose "No, I want a separate bill for each MPRN"
        click_button "Save and continue"

        # Back to Check page
        expect(page).to have_text("Check your answers")
        expect(page).to have_text(new_mprn)
      end
    end
  end

  describe "Electricity meters and usage" do
    let(:new_mpan) { "923457" }

    context "Single meter has been specified" do
      before do
        expect(page).to have_text("Electricity information")
        find("#electric_meters_and_usage_change").click

        # Land on single or multi meter screen
        save_and_open_page
        expect(page).to have_text("Electricity meters and usage")
        expect(page).to have_text("Is this a single or multi meter site?")
        expect(page).not_to have_button("Save and go to tasks")
      end
      context "Stay with single meter" do
        pending
        specify "Clicking 'Change'" do
          choose "Single meter"
          click_button "Save and continue"

          # Land on the edit screen for the single meter
          expect(page).to have_text("Gas meter details")
          expect(page).not_to have_button("Save and go to tasks")
          expect(page).to have_field("Add a Meter Point Reference Number (MPRN)", with: gas_meter_numbers.first)
          fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "1234"
          click_button "Save and continue"

          # Land back on Check page
          expect(page).to have_text("Check your answers")
        end
      end
      context "Change to multi meter" do
        pending
        specify "Clicking 'Change'" do
          choose "Multi meter"
          click_button "Save and continue"

          # Land on the new screen for the single meter
          expect(page).to have_text("Gas meter details")
          expect(page).not_to have_button("Save and go to tasks")
          fill_in "Add a Meter Point Reference Number (MPRN)", with: new_mprn
          fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "1234"
          click_button "Save and continue"

          # Land on meter list
          expect(page).to have_text("MPRN summary")
          expect(page).not_to have_button("Save and go to tasks")
          find("#save_and_continue").click

          # Land on consolidation screen
          expect(page).to have_text("Do you want your MPRNs consolidated on one bill?")
          expect(page).not_to have_button("Save and go to tasks")
          choose "No, I want a separate bill for each MPRN"
          click_button "Save and continue"

          # Back to Check page
          expect(page).to have_text("Check your answers")
          expect(page).to have_text(new_mprn)
        end
      end
    end

    context "Multi meter has been specified" do
      let(:gas_single_multi) { "multi" }
      let(:gas_meter_numbers) { %w[654321 765432] }

      specify "Clicking 'Change'" do
        pending
        expect(page).to have_text("Gas information")
        find("#gas_meters_and_usage_change").click

        # Land on gas meter list
        expect(page).to have_text("MPRN summary")
        expect(page).not_to have_button("Save and go to tasks")

        # Add a meter
        find("#add_another_mprn").click # click_button "Add another MPRN" results in: Unable to find button "Add another MPRN" that is not disabled
        # Land on Gas meter details
        expect(page).to have_text("Gas meter details")
        expect(page).not_to have_button("Save and go to tasks")
        fill_in "Add a Meter Point Reference Number (MPRN)", with: new_mprn
        fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "123"
        click_button "Save and continue"
        # Back on meter list
        expect(page).to have_text("MPRN summary")

        # Delete a meter
        within "table > tbody > tr:nth-child(1)" do
          find(".remove_meter").click
        end
        # Land on confirm screen
        expect(page).to have_text("Are you sure you want to remove this MPRN?")
        find(".remove_meter").click
        # Back on meter list
        expect(page).to have_text("MPRN summary")

        # Change a meter
        within "table > tbody > tr:nth-child(1)" do
          click_link "Change"
        end
        # Land on edit page
        expect(page).to have_text("Gas meter details")
        fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "5432"
        click_button "Save and continue"
        # Back on meter list
        expect(page).to have_text("MPRN summary")
        find("#save_and_continue").click

        # Land on consolidation screen
        expect(page).to have_text("Do you want your MPRNs consolidated on one bill?")
        expect(page).not_to have_button("Save and go to tasks")
        choose "No, I want a separate bill for each MPRN"
        click_button "Save and continue"

        # Back to Check page
        expect(page).to have_text("Check your answers")
        expect(page).to have_text(new_mprn)
      end
    end
  end

  describe "Site contact details" do
    specify "Clicking 'Change'" do
      expect(page).to have_text("Site contact details")
      find("#site_contact_details_change").click

      # Land on Site contact
      expect(page).to have_text("Who manages site access and maintenance?")
      expect(page).not_to have_button("Save and go to tasks")
      fill_in "First name", with: "Penelope"
      click_button "Save and continue"

      # Back to Check page
      expect(page).to have_text("Check your answers")
      expect(page).to have_text("Penelope")
    end
  end

  describe "VAT declaration" do
		context "Correct details" do
      pending
    end
		context "Incorrect details" do
      pending
    end
  end

  describe "Billing preferences" do
    pending
  end
end

