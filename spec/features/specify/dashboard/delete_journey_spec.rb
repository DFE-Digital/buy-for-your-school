RSpec.feature "Delete a journey" do
  let(:user) { create(:user) }

  context "with an existing deleted journey" do
    before do
      create(:journey,
             user:,
             category: create(:category, :mfd),
             created_at: Time.zone.local(2021, 2, 15, 12, 0, 0))

      create(:journey,
             user:,
             state: 3,
             category: create(:category, :catering),
             created_at: Time.zone.local(2021, 3, 20, 12, 0, 0))

      user_is_signed_in(user:)
      visit "/dashboard"
    end

    scenario "the deleted journey is not shown in the table" do
      within("tbody.govuk-table__body") do
        expect(page).to have_css "tr.govuk-table__row", count: 1
        expect(page).to have_text "15 February 2021"
        expect(page).to have_text "Multi-functional devices"
      end
    end
  end

  context "when a user deletes existing journey" do
    let!(:specification) do
      create(:journey,
             user:,
             category: create(:category, :catering),
             created_at: Time.zone.local(2021, 3, 20, 12, 0, 0))
    end

    before do
      user_is_signed_in(user:)
      visit "/dashboard"
    end

    it "table has delete button" do
      within("tbody.govuk-table__body") do
        expect(page).to have_css "tr.govuk-table__row", count: 1
        expect(page).to have_text "Delete"
      end
    end

    it "shows the confirm delete page and delete button" do
      within("tbody.govuk-table__body") do
        click_link("Delete")
      end

      expect(page.title).to have_text "Are you sure you want to delete this specification?"

      click_link("Delete specification")

      expect(page.title).to have_text "This specification has been deleted"
      specification.reload

      expect(specification.state).to eq "remove"
    end
  end
end
