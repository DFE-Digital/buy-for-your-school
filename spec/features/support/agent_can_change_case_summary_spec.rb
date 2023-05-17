require "rails_helper"

describe "Agent can change case summary" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, support_level: nil, value: nil, source: "nw_hub") }

  before do
    visit support_case_path(support_case)
    within "h3", text: "Case summary - change" do
      click_link "change"
    end
  end

  context "when the support level is updated" do
    before do
      choose "1 - General guidance"
      click_button "Continue"
      click_button "Save"
      support_case.reload
    end

    it "persists the changed support_level" do
      expect(support_case.support_level).to eq "L1"
    end

    it "creates a support level changed interaction" do
      interaction = Support::Interaction.first

      expect(interaction.body).to eq "Case support level changed"
      expect(interaction.additional_data).to eq({
        "format_version" => "2",
        "support_level" => "L1",
      })
    end
  end

  context "when the case value is updated" do
    before do
      fill_in "Case value or estimated contract value (optional)", with: "123.32"
      click_button "Continue"
      click_button "Save"
      support_case.reload
    end

    it "persists the changed case value" do
      expect(support_case.value).to eq(123.32)
    end

    it "creates a value change interaction" do
      interaction = Support::Interaction.first

      expect(interaction.body).to eq "Case value changed"
      expect(interaction.additional_data).to eq({
        "format_version" => "2",
        "procurement_value" => "123.32",
      })
    end
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
      expect(interaction.additional_data).to eq({
        "format_version" => "2",
        "source" => "incoming_email",
      })
    end
  end
end
