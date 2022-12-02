RSpec.feature "Creating an energy request" do
  describe "start page" do
    before do
      visit "/procurement-support"
      click_on "Start now"
    end

    it "continues to the energy request question" do
      expect(page).to have_text "Is your request about energy?"
    end
  end

  describe "energy request question" do
    before { visit "/procurement-support/energy_request" }

    it "goes back to the start page" do
      click_on "Back"
      expect(page).to have_text "Request help and support for your procurement"
    end

    context "when the request is about energy" do
      before do
        choose "Yes"
        click_continue
      end

      it "continues to the about question" do
        expect(page).to have_text "What's your energy request about?"
      end
    end

    context "when the request is not about energy" do
      before do
        choose "No"
        click_continue
      end

      it "continues to the sign in page" do
        expect(page).to have_text "Do you have a DfE Sign-in account linked to the school that your request is about?"
      end
    end
  end

  describe "energy request about question" do
    before { visit "/procurement-support/energy_request_about" }

    it "goes back to the energy request question" do
      click_on "Back"
      expect(page).to have_text "Is your request about energy?"
    end

    context "when the request is about an energy contract" do
      before do
        choose "An energy contract, for example, renewal"
        click_continue
      end

      it "continues to the recent bill question" do
        expect(page).to have_text "Do you have a recent energy bill you can upload?"
      end
    end

    context "when the request is about a general question" do
      before do
        choose "A general question about energy"
        click_continue
      end

      it "continues to the sign in page" do
        expect(page).to have_text "Do you have a DfE Sign-in account linked to the school that your request is about?"
      end
    end

    context "when the request is about something else" do
      before do
        choose "Something else"
        click_continue
      end

      it "continues to the sign in page" do
        expect(page).to have_text "Do you have a DfE Sign-in account linked to the school that your request is about?"
      end
    end
  end

  describe "recent bill question" do
    before { visit "/procurement-support/energy_bill" }

    it "goes back to the about question" do
      click_on "Back"
      expect(page).to have_text "What's your energy request about?"
    end

    context "when they have a recent bill" do
      before do
        choose "Yes"
        click_continue
      end

      it "continues to the sign in page" do
        expect(page).to have_text "Do you have a DfE Sign-in account linked to the school that your request is about?"
      end
    end

    context "when they don't have a recent bill" do
      before do
        choose "No"
        click_continue
      end

      it "continues to the alternative energy information question" do
        expect(page).to have_text "Would you like to provide us with your energy information in another way?"
      end
    end
  end

  describe "alternative energy information question" do
    before { visit "/procurement-support/energy_alternative" }

    it "goes back to the recent bill question" do
      click_on "Back"
      expect(page).to have_text "Do you have a recent energy bill you can upload?"
    end

    context "when they can upload a different format" do
      before do
        choose "I can upload my energy information in a different format, such as in a document or a spreadsheet"
        click_continue
      end

      it "continues to the sign in page" do
        expect(page).to have_text "Do you have a DfE Sign-in account linked to the school that your request is about?"
      end
    end

    context "when they want to email the bills" do
      before do
        choose "I want to email my bills at a later date"
        click_continue
      end

      it "continues to the sign in page" do
        expect(page).to have_text "Do you have a DfE Sign-in account linked to the school that your request is about?"
      end
    end

    context "when they have never had an energy bill before" do
      before do
        choose "I've never had an energy bill before"
        click_continue
      end

      it "continues to the sign in page" do
        expect(page).to have_text "Do you have a DfE Sign-in account linked to the school that your request is about?"
      end
    end

    context "when they refuse" do
      before do
        choose "No thank you"
        click_continue
      end

      it "continues to the sign in page" do
        expect(page).to have_text "Do you have a DfE Sign-in account linked to the school that your request is about?"
      end
    end
  end
end
