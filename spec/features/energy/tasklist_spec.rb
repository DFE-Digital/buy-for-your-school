require "rails_helper"

describe "Tasklist flows", :js do
  include_context "with energy suppliers"

  before do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    case_organisation.update!(gas_single_multi:, electricity_meter_type:)
    support_organisation.update!(address: { "street": "5 Main Street", "locality": "Duke's Place", "postcode": "EC3A 5DE" })

    gas_meter_numbers.each do |mprn|
      create(:energy_gas_meter, :with_valid_data, mprn:, onboarding_case_organisation: case_organisation)
    end

    electricity_meter_numbers.each do |mpan|
      create(:energy_electricity_meter, :with_valid_data, mpan:, energy_onboarding_case_organisation_id: case_organisation.id)
    end

    # Visit Tasklist
    visit energy_case_tasks_path(onboarding_case)
  end

  let(:gas_single_multi) { "single" }
  let(:gas_meter_numbers) { %w[654321] }
  let(:electricity_meter_type) { "single" }
  let(:electricity_meter_numbers) { %w[1234567890123] }

  describe "Gas contract" do
    it "directs to the gas contract page and back to the tasklist" do
      expect(page).to have_text("Gas contract information")
      click_link("Gas contract information")

      # Go to Gas Contract
      expect(page).to have_text("Gas Contract")
      expect(page).to have_button("Discard and go to task list")
      choose "Other"
      fill_in "Gas supplier", with: "Great Gas Ltd"
      click_button "Save and continue"

      # Back to Tasklist
      expect(page).to have_text("Provide information about your schools")
    end
  end

  describe "Electricity contract" do
    it "directs to the electricity contract page and back to the tasklist" do
      expect(page).to have_text("Electricity contract information")
      click_link("Electricity contract information")

      # Go to Electricity Contract
      expect(page).to have_text("Electricity Contract")
      expect(page).to have_button("Discard and go to task list")
      choose "Other"
      fill_in "Electricity supplier", with: "Emilys Leccie Co"
      click_button "Save and continue"

      # Back to Tasklist
      expect(page).to have_text("Provide information about your schools")
    end
  end

  describe "Gas meters and usage" do
    let(:new_mprn) { "923457" }

    context "when a single meter has already been specified and needs to stay as a single meter" do
      it "navigates to the single/multi meter choice page, then gas meter details, then back to the tasklist" do
        expect(page).to have_text("Gas meter and usage")
        click_link("Gas meter and usage")

        # Go to single/multi meter screen
        expect(page).to have_text("Is this a single or multi meter site?")
        expect(page).to have_button("Discard and go to task list")
        choose "Single meter"
        click_button "Save and continue"

        # Go to meter details
        expect(page).to have_text("Gas meter details")
        expect(page).to have_button("Discard and go to task list")
        expect(page).to have_field("Add a Meter Point Reference Number (MPRN)", with: gas_meter_numbers.first)
        fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "123"
        click_button "Save and continue"

        # Back to Tasklist
        expect(page).to have_text("Provide information about your schools")
      end
    end

    context "when a single meter has already been specified and needs to change to a multi meter" do
      it "navigates to the single/multi meter choice page, then the meter details page, then MPRN summary, then bill consolidation, then back to CYA" do
        expect(page).to have_text("Gas meter and usage")
        click_link("Gas meter and usage")

        # Go to single/multi meter screen
        expect(page).to have_text("Is this a single or multi meter site?")
        expect(page).to have_button("Discard and go to task list")
        choose "Multi meter"
        click_button "Save and continue"

        # Go to meter details
        expect(page).to have_text("Gas meter details")
        expect(page).to have_button("Discard and go to task list")
        fill_in "Add a Meter Point Reference Number (MPRN)", with: new_mprn
        fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "1234"
        click_button "Save and continue"

        # Go to MPRN summary
        expect(page).to have_text("MPRN summary")
        expect(page).to have_button("Discard and go to task list")
        find("#save_and_continue").click

        # Go to bill consolidation screen
        expect(page).to have_text("Do you want your MPRNs consolidated on one bill?")
        expect(page).to have_button("Discard and go to task list")
        choose "No, I want a separate bill for each MPRN"
        click_button "Save and continue"

        # Back to Tasklist
        expect(page).to have_text("Provide information about your schools")
      end
    end

    context "when a multi meter and meter detail has already been specified" do
      let(:gas_single_multi) { "multi" }
      let(:gas_meter_numbers) { %w[654321 765432] }

      it "navigates to the MPRN summary, then through adding more numbers, then bill consolidation, then back to the tasklist" do
        expect(page).to have_text("Gas meter and usage")
        click_link("Gas meter and usage")

        # Go to MPRN summary
        expect(page).to have_text("MPRN summary")
        expect(page).to have_button("Discard and go to task list")

        # Add a meter
        find("#add_another_mprn").click # click_button "Add another MPRN" results in: Unable to find button "Add another MPRN" that is not disabled

        # Go to Gas meter details
        expect(page).to have_text("Gas meter details")
        expect(page).to have_button("Discard and go to task list")
        fill_in "Add a Meter Point Reference Number (MPRN)", with: new_mprn
        fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "123"
        click_button "Save and continue"

        # Back to MPRN summary
        expect(page).to have_text("MPRN summary")

        # Delete a meter
        within "table > tbody > tr:nth-child(1)" do
          find(".remove_meter").click
        end

        # Go to confirm screen
        expect(page).to have_text("Are you sure you want to remove this MPRN?")
        find(".remove_meter").click

        # Back to MPRN summary
        expect(page).to have_text("MPRN summary")

        # Change a meter
        within "table > tbody > tr:nth-child(1)" do
          click_link "Change"
        end

        # Go to Gas meter details
        expect(page).to have_text("Gas meter details")
        fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "5432"
        click_button "Save and continue"

        # Back to MPRN summary
        expect(page).to have_text("MPRN summary")
        find("#save_and_continue").click

        # Go to bill consolidation screen
        expect(page).to have_text("Do you want your MPRNs consolidated on one bill?")
        expect(page).to have_button("Discard and go to task list")
        choose "No, I want a separate bill for each MPRN"
        click_button "Save and continue"

        # Back to Tasklist
        expect(page).to have_text("Provide information about your schools")
      end
    end

    context "when a multi meter has already been specified but there are no meter details" do
      let(:gas_single_multi) { "multi" }

      it "navigates to the single/multi meter choice page, then the meter details page, then the MPRN summary, then through adding more numbers, then bill consolidation, then back to the tasklist" do
        expect(page).to have_text("Gas meter and usage")
        click_link("Gas meter and usage")

        # Go to single/multi meter screen
        expect(page).to have_text("Is this a single or multi meter site?")
        expect(page).to have_button("Discard and go to task list")
        choose "Multi meter"
        click_button "Save and continue"

        # Go to meter details
        expect(page).to have_text("Gas meter details")
        expect(page).to have_button("Discard and go to task list")
        expect(page).to have_field("Add a Meter Point Reference Number (MPRN)", with: gas_meter_numbers.first)
        fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "123"
        click_button "Save and continue"

        # Go to MPRN summary
        expect(page).to have_text("MPRN summary")
        expect(page).to have_button("Discard and go to task list")

        # Add a meter
        find("#add_another_mprn").click # click_button "Add another MPRN" results in: Unable to find button "Add another MPRN" that is not disabled

        # Go to Gas meter details
        expect(page).to have_text("Gas meter details")
        expect(page).to have_button("Discard and go to task list")
        fill_in "Add a Meter Point Reference Number (MPRN)", with: new_mprn
        fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "123"
        click_button "Save and continue"

        # Back to MPRN summary
        expect(page).to have_text("MPRN summary")

        # Delete a meter
        within "table > tbody > tr:nth-child(1)" do
          find(".remove_meter").click
        end

        # Go to confirm screen
        expect(page).to have_text("Are you sure you want to remove this MPRN?")
        find(".remove_meter").click

        # Back to MPRN summary
        expect(page).to have_text("MPRN summary")

        # Change a meter
        within "table > tbody > tr:nth-child(1)" do
          click_link "Change"
        end

        # Go to Gas meter details
        expect(page).to have_text("Gas meter details")
        fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "5432"
        click_button "Save and continue"

        # Back to MPRN summary
        expect(page).to have_text("MPRN summary")
        find("#save_and_continue").click

        # Go to bill consolidation screen
        expect(page).to have_text("Do you want your MPRNs consolidated on one bill?")
        expect(page).to have_button("Discard and go to task list")
        choose "No, I want a separate bill for each MPRN"
        click_button "Save and continue"

        # Back to Tasklist
        expect(page).to have_text("Provide information about your schools")
      end
    end
  end

  describe "Electricity meters and usage" do
    let(:new_mpan) { "1234567890124" }

    context "when a single meter has already been specified and needs to stay as a single meter" do
      it "navigates to the single/multi meter choice page, then electric meter details, then back to tasklist" do
        expect(page).to have_text("Electricity contract information")
        click_link("Electricity contract information")

        # Go to single/multi meter screen
        expect(page).to have_text("Is this a single or multi meter site?")
        expect(page).to have_button("Discard and go to task list")
        choose "Single meter"
        click_button "Save and continue"

        # Go to meter details
        expect(page).to have_text("Electricity meter details")
        expect(page).to have_button("Discard and go to task list")
        expect(page).to have_field("Add an MPAN", with: electricity_meter_numbers.first)
        fill_in "Estimated annual electricity usage", with: "1234"
        click_button "Save and continue"

        # Back to Tasklist
        expect(page).to have_text("Provide information about your schools")
      end
    end

    context "when a single meter has already been specified and needs to change to a multi meter" do
      it "navigates to the single/multi meter choice page, then the meter details page, then MPAN summary, then bill consolidation, then back to tasklist" do
        click_link("Electricity contract information")

        # Go to single/multi meter screen
        expect(page).to have_text("Is this a single or multi meter site?")
        expect(page).to have_button("Discard and go to task list")
        choose "Multi meter"
        click_button "Save and continue"

        # Go to meter details
        expect(page).to have_text("Electricity meter details")
        expect(page).to have_button("Discard and go to task list")
        fill_in "Add an MPAN", with: new_mpan
        choose "No"
        fill_in "Estimated annual electricity usage", with: "1234"
        click_button "Save and continue"

        # Go to MPAN summary
        expect(page).to have_text("MPAN summary")
        expect(page).to have_button("Discard and go to task list")
        click_on "Save and continue"

        # Go to bill consolidation screen
        expect(page).to have_text("Do you want your MPANs consolidated on one bill?")
        expect(page).to have_button("Discard and go to task list")
        choose "No, I want a separate bill for each MPAN"
        click_button "Save and continue"

        # Back to Tasklist
        expect(page).to have_text("Provide information about your schools")
      end
    end

    context "when a multi meter and meter detail has already been specified" do
      let(:electricity_meter_type) { "multi" }
      let(:electricity_meter_numbers) { %w[1234567890987 1234567890986] }

      it "navigates to the MPAN summary, then through adding more numbers, then bill consolidation, then back to the tasklist" do
        click_link("Electricity contract information")

        # Go to MPAN summary
        expect(page).to have_text("MPAN summary")
        expect(page).to have_button("Discard and go to task list")

        # Add a meter
        click_on "Add another MPAN"

        # Go to Electricity meter details
        expect(page).to have_text("Electricity meter details")
        expect(page).to have_button("Discard and go to task list")
        fill_in "Add an MPAN", with: new_mpan
        choose "No"
        fill_in "Estimated annual electricity usage", with: "123"
        click_button "Save and continue"

        # Back to MPAN summary
        expect(page).to have_text("MPAN summary")

        # Delete a meter
        within "table > tbody > tr:nth-child(1)" do
          click_on "Remove"
        end

        # Go to confirm screen
        expect(page).to have_text("Are you sure you want to remove this MPAN?")
        click_on "Remove MPAN"

        # Back to MPAN summary
        expect(page).to have_text("MPAN summary")

        # Change a meter
        within "table > tbody > tr:nth-child(1)" do
          click_link "Change"
        end

        # Go to Electricity meter details
        expect(page).to have_text("Electricity meter details")
        fill_in "Estimated annual electricity usage", with: "5432"
        click_button "Save and continue"

        # Back to MPAN summary
        expect(page).to have_text("MPAN summary")
        click_on "Save and continue"

        # Go to bill consolidation screen
        expect(page).to have_text("Do you want your MPANs consolidated on one bill?")
        expect(page).to have_button("Discard and go to task list")
        choose "No, I want a separate bill for each MPAN"
        click_button "Save and continue"

        # Back to Tasklist
        expect(page).to have_text("Provide information about your schools")
      end
    end

    context "when a multi meter has already been specified but there are no meter details" do
      let(:electricity_meter_type) { "multi" }

      it "navigates to the single/multi meter choice page, then electric meter details, then the MPAN summary, then through adding more numbers, then bill consolidation, then back to the tasklist" do
        click_link("Electricity contract information")

        # Go to single/multi meter screen
        expect(page).to have_text("Is this a single or multi meter site?")
        expect(page).to have_button("Discard and go to task list")
        choose "Multi meter"
        click_button "Save and continue"

        # Go to meter details
        expect(page).to have_text("Electricity meter details")
        expect(page).to have_button("Discard and go to task list")
        expect(page).to have_field("Add an MPAN", with: electricity_meter_numbers.first)
        fill_in "Estimated annual electricity usage", with: "1234"
        click_button "Save and continue"

        # Go to MPAN summary
        expect(page).to have_text("MPAN summary")
        expect(page).to have_button("Discard and go to task list")

        # Add a meter
        click_on "Add another MPAN"

        # Go to Electricity meter details
        expect(page).to have_text("Electricity meter details")
        expect(page).to have_button("Discard and go to task list")
        fill_in "Add an MPAN", with: new_mpan
        choose "No"
        fill_in "Estimated annual electricity usage", with: "123"
        click_button "Save and continue"

        # Back to MPAN summary
        expect(page).to have_text("MPAN summary")

        # Delete a meter
        within "table > tbody > tr:nth-child(1)" do
          click_on "Remove"
        end

        # Go to confirm screen
        expect(page).to have_text("Are you sure you want to remove this MPAN?")
        click_on "Remove MPAN"

        # Back to MPAN summary
        expect(page).to have_text("MPAN summary")

        # Change a meter
        within "table > tbody > tr:nth-child(1)" do
          click_link "Change"
        end

        # Go to Electricity meter details
        expect(page).to have_text("Electricity meter details")
        fill_in "Estimated annual electricity usage", with: "5432"
        click_button "Save and continue"

        # Back to MPAN summary
        expect(page).to have_text("MPAN summary")
        click_on "Save and continue"

        # Go to bill consolidation screen
        expect(page).to have_text("Do you want your MPANs consolidated on one bill?")
        expect(page).to have_button("Discard and go to task list")
        choose "No, I want a separate bill for each MPAN"
        click_button "Save and continue"

        # Back to Tasklist
        expect(page).to have_text("Provide information about your schools")
      end
    end
  end

  describe "Site contact details" do
    context "when changing site contact details" do
      it "navigates to the site contact details page, then back to the tasklist" do
        expect(page).to have_text("Site contact details")
        click_link("Site contact details")

        # Go to Site contact
        expect(page).to have_text("Who manages site access and maintenance?")
        expect(page).to have_button("Discard and go to task list")
        fill_in "First name", with: "Penelope"
        click_button "Save and continue"

        # Back to Tasklist
        expect(page).to have_text("Provide information about your schools")
      end
    end
  end

  describe "VAT declaration" do
    context "when VAT rate needs to be 20%" do
      it "navigates from VAT rate selection, back to the tasklist" do
        click_link("VAT declaration")

        # Go to VAT rate selection page
        expect(page).to have_text("Which VAT rate are you charged?")
        expect(page).to have_button("Discard and go to task list")
        choose "20%"
        click_button "Save and continue"

        # Back to Tasklist
        expect(page).to have_text("Provide information about your schools")
      end
    end

    context "when VAT rate needs to be 5%" do
      context "and contact details are correct" do
        it "navigates from VAT rate selection, to the current contract details page, to the declaration page, back to the tasklist" do
          click_link("VAT declaration")

          # Go to VAT rate selection page
          expect(page).to have_text("Which VAT rate are you charged?")
          expect(page).to have_button("Discard and go to task list")
          choose "5%"
          fill_in "Percentage of total consumption qualifying for reduced rate of VAT", with: "25"
          click_button "Save and continue"

          # Go to current contract details page
          expect(page).to have_text("Are these the correct details for VAT purposes?")
          expect(page).to have_button("Discard and go to task list")
          choose "Yes"
          click_button "Save and continue"

          # Go to declaration page
          expect(page).to have_text("VAT certificate of declaration")
          expect(page).to have_button("Discard and go to task list")
          find("#vat-certificate-form-vat-certificate-declared-declaration1-field").check
          find("#vat-certificate-form-vat-certificate-declared-declaration2-field").check
          find("#vat-certificate-form-vat-certificate-declared-declaration3-field").check
          click_button "Continue"

          # Back to Tasklist
          expect(page).to have_text("Provide information about your schools")
        end
      end

      context "and contact details are incorrect" do
        before do
          create(:support_establishment_group, :with_address, uid: "123")
          support_organisation.update!(trust_code: "123")
        end

        it "navigates from VAT rate selection, to the current contract details page, to the VAT contact information page, to the declaration page, back to the tasklist" do
          click_link("VAT declaration")

          # Go to VAT rate selection page
          expect(page).to have_text("Which VAT rate are you charged?")
          expect(page).to have_button("Discard and go to task list")
          choose "5%"
          fill_in "Percentage of total consumption qualifying for reduced rate of VAT", with: "25"
          click_button "Save and continue"

          # Go to current contract details page
          expect(page).to have_text("Are these the correct details for VAT purposes?")
          expect(page).to have_button("Discard and go to task list")
          choose "No"
          click_button "Save and continue"

          # Go to contact information page
          expect(page).to have_text("VAT contact information")
          expect(page).to have_button("Discard and go to task list")
          fill_in "First name", with: "Jane"
          fill_in "Telephone number", with: "07123456789"
          choose "5 Main Street, Duke's Place, EC3A 5DE"
          click_button "Save and continue"

          # Go to declaration page
          expect(page).to have_text("VAT certificate of declaration")
          expect(page).to have_button("Discard and go to task list")
          find("#vat-certificate-form-vat-certificate-declared-declaration1-field").check
          find("#vat-certificate-form-vat-certificate-declared-declaration2-field").check
          find("#vat-certificate-form-vat-certificate-declared-declaration3-field").check
          click_button "Continue"

          # Back to Tasklist
          expect(page).to have_text("Provide information about your schools")
        end
      end
    end
  end

  describe "Billing preferences" do
    context "when changing billing preferences to be email" do
      it "navigates to the billing preferences page, then back to the tasklist" do
        click_link("Billing preferences")

        # Go to Billing preferences
        expect(page).to have_text("Billing preferences")
        expect(page).to have_button("Discard and go to task list")
        choose "BACS"
        choose "21 days"
        choose "Email"
        fill_in "Email address", with: "test@test.com"
        click_button "Save and continue"

        # Back to Tasklist
        expect(page).to have_text("Provide information about your schools")
      end
    end

    context "when changing billing preferences to be paper and the org is a single school without a trust" do
      it "navigates to the billing preferences page, then back to the tasklist" do
        click_link("Billing preferences")

        # Go to Billing preferences
        expect(page).to have_text("Billing preferences")
        expect(page).to have_button("Discard and go to task list")
        choose "BACS"
        choose "21 days"
        choose "Paper"
        click_button "Save and continue"

        # Back to Tasklist
        expect(page).to have_text("Provide information about your schools")
      end
    end

    context "when changing billing preferences to be paper and the org is a single school with a trust" do
      before do
        create(:support_establishment_group, :with_address, uid: "123")
        support_organisation.update!(trust_code: "123")
      end

      it "navigates to the site billing preferences page, then to address confirmation page, then back to the tasklist" do
        click_link("Billing preferences")

        # Go to Billing preferences
        expect(page).to have_text("Billing preferences")
        expect(page).to have_button("Discard and go to task list")
        choose "BACS"
        choose "21 days"
        choose "Paper"
        click_button "Save and continue"

        # Go to Address confirmation page
        expect(page).to have_text("Billing address")
        expect(page).to have_text("5 Main Street")
        expect(page).to have_text("Boundary House Shr")
        expect(page).to have_button("Discard and go to task list")
        choose "5 Main Street, Duke's Place, EC3A 5DE"
        click_button "Save and continue"

        # Back to Tasklist
        expect(page).to have_text("Provide information about your schools")
      end
    end
  end
end
