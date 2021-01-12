feature "Users can see their catering specification" do
  scenario "HTML" do
    liquid_template = stub_liquid_template(filename: "food_catering.liquid")
    journey = create(:journey, :catering, liquid_template: liquid_template)
    step = create(:step, :long_text, long_text_answer: nil, journey: journey, contentful_id: "NxJWpbiFeEAmvcw17EysX")
    answer = create(:long_text_answer, step: step, response: "Red tractor")

    visit journey_path(journey)

    expect(page).to have_content(I18n.t("journey.specification.header"))

    within("article#specification") do
      expect(page).to have_content("Menus and ordering")
      expect(page).to have_content("Food standards")
      expect(page).to have_content("The school also requires the service to comply with the following non-mandatory food standards or schemes:")
      expect(page).to have_content(answer.response)
    end
  end
end
