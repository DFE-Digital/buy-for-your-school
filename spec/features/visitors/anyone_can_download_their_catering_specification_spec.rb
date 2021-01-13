feature "Users can see their catering specification" do
  scenario "HTML" do
    journey = create(:journey, :catering, liquid_template: stub_liquid_template)
    step = create(:step, :long_text, long_text_answer: nil, journey: journey, contentful_id: "NxJWpbiFeEAmvcw17EysX")
    _answer = create(:long_text_answer, step: step, response: "Red tractor")

    visit journey_path(journey)

    expect(page).to have_content(I18n.t("journey.specification.header"))

    click_on("Download (.docx)")

    expect(page.response_headers["Content-Type"]).to eql("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
    header = page.response_headers["Content-Disposition"]
    expect(header).to match(/^attachment/)
    expect(header).to match(/filename="specification.docx"/)
  end

  def stub_liquid_template
    fake_liquid_template = File.read("#{Rails.root}/spec/fixtures/specification_templates/food_catering.liquid")

    finder = instance_double(FindLiquidTemplate)
    allow(FindLiquidTemplate).to receive(:new).with(category: "catering")
      .and_return(finder)
    allow(finder).to receive(:call).and_return(fake_liquid_template)

    fake_liquid_template
  end
end
