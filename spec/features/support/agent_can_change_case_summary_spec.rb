require "rails_helper"

describe "Agent can change case summary" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, support_level: nil, value: nil, source: "nw_hub") }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    within "h3", text: "Case summary - change" do
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

  context "when the case source is updated" do
    before do
      select "Email", from: "Case source"
      click_button "Continue"
      click_button "Save"
      support_case.reload
    end

    it "persists the changed case source" do
      expect(support_case.source).to eq "incoming_email"
    end

    it "creates a source change interaction" do
      interaction = Support::Interaction.first
      expect(interaction.body).to eq "Source changed"
      expect(interaction.additional_data).to eq({ "to" => "incoming_email", "from" => "nw_hub" })
    end
  end
end
