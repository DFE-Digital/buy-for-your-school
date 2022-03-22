require "rails_helper"

describe "Agent can change case summary" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, support_level: nil, value: nil) }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    within "h2", text: "Case summary - change" do
      click_link "change"
    end
  end

  it "persists the changed support_level" do
    choose "1 - General guidance"
    click_button "Continue"
    click_button "Save"
    support_case.reload

    expect(support_case.support_level).to eq "L1"
  end

  it "persists the changed case value" do
    fill_in "Case value or estimated contract value (optional)", with: "123.32"
    click_button "Continue"
    click_button "Save"
    support_case.reload

    expect(support_case.value).to eq(123.32)
  end
end
