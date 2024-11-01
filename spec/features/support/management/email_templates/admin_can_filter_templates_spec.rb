require "rails_helper"

describe "Admin can filter templates", :js, bullet: :skip do
  include_context "with an agent", roles: %w[global_admin]

  before do
    group_energy = create(:support_email_template_group, title: "Energy")
    subgroup_energy_solar = create(:support_email_template_group, title: "Solar", parent: group_energy)
    group_fm = create(:support_email_template_group, title: "FM")
    subgroup_fm_catering = create(:support_email_template_group, title: "Catering", parent: group_fm)
    subgroup_fm_cleaning = create(:support_email_template_group, title: "Cleaning", parent: group_fm)

    create(:support_email_template, group: group_energy, title: "Energy template", stage: nil)
    create(:support_email_template, group: subgroup_energy_solar, title: "Solar template", stage: 1)
    create(:support_email_template, group: group_fm, title: "FM template", stage: 2)
    create(:support_email_template, group: subgroup_fm_catering, title: "Catering template", stage: 4)
    create(:support_email_template, group: subgroup_fm_cleaning, title: "Cleaning template", stage: nil)

    visit support_management_email_templates_path
  end

  describe "Admin viewing email templates" do
    it "shows all templates" do
      expect(page).to have_text "5 templates"
      expect(page).to have_text "Energy template"
      expect(page).to have_text "Solar template"
      expect(page).to have_text "FM template"
      expect(page).to have_text "Catering template"
      expect(page).to have_text "Cleaning template"
    end

    it "shows default filter settings" do
      expect(page).to have_select "Select group", selected: "All groups"
      expect(page).to have_checked_field "All stages"
      expect(page).to have_css "div.expander[disabled]", text: "Subgroups"
    end
  end

  describe "Admin viewing email templates selects to filter by group" do
    before do
      select "Energy", from: "Select group"
    end

    it "shows the templates in that group" do
      expect(page).to have_text "2 templates"
      expect(page).to have_text "Energy template"
      expect(page).to have_text "Solar template"
    end

    it "shows the selected filters" do
      expect(page).to have_select "Select group", selected: "Energy"
      expect(page).to have_checked_field "All subgroups"
      expect(page).to have_checked_field "All stages"
      expect(page).to have_css "span.tag-bar__tag", text: "Energy"
    end
  end

  describe "Admin viewing email templates selects to filter by subgroup" do
    before do
      select "FM", from: "Select group"
      within("div.expander", text: "Subgroups") { check "Cleaning" }
    end

    it "shows the templates in that subgroup" do
      expect(page).to have_text "1 template"
      expect(page).to have_text "Cleaning template"
    end

    it "shows the selected filters" do
      expect(page).to have_select "Select group", selected: "FM"
      expect(page).to have_checked_field "Cleaning"
      expect(page).to have_checked_field "All stages"
      expect(page).to have_css "span.tag-bar__tag", text: "FM"
      expect(page).to have_css "span.tag-bar__tag", text: "Cleaning"
    end
  end

  describe "Admin viewing email templates selects to filter by stage" do
    before do
      select "FM", from: "Select group"
      within("div.expander", text: "Stages") { check "Stage 4" }
    end

    it "shows the templates in that subgroup" do
      expect(page).to have_text "1 template"
      expect(page).to have_text "Catering template"
    end

    it "shows the selected filters" do
      expect(page).to have_select "Select group", selected: "FM"
      expect(page).to have_checked_field "All subgroups"
      expect(page).to have_checked_field "Stage 4"
      expect(page).to have_css "span.tag-bar__tag", text: "FM"
      expect(page).to have_css "span.tag-bar__tag", text: "Stage 4"
    end
  end

  describe "Admin viewing email templates selects to filter by subgroup and stage" do
    before do
      select "FM", from: "Select group"
      within("div.expander", text: "Subgroups") { check "Cleaning" }
      within("div.expander", text: "Stages") { check "No stage" }
    end

    it "shows the templates in that subgroup" do
      expect(page).to have_text "1 template"
      expect(page).to have_text "Cleaning template"
    end

    it "shows the selected filters" do
      expect(page).to have_select "Select group", selected: "FM"
      expect(page).to have_checked_field "Cleaning"
      expect(page).to have_checked_field "No stage"
      expect(page).to have_css "span.tag-bar__tag", text: "FM"
      expect(page).to have_css "span.tag-bar__tag", text: "Cleaning"
      expect(page).to have_css "span.tag-bar__tag", text: "No stage"
    end

    context "when a tag is removed" do
      before do
        within("span.tag-bar__tag", text: "Cleaning") { click_button "✕" }
        within("span.tag-bar__tag", text: "FM") { click_button "✕" }
      end

      it "shows results without that filter" do
        expect(page).to have_text "2 templates"
        expect(page).to have_text "Energy template"
        expect(page).to have_text "Cleaning template"
      end

      it "shows the selected filters" do
        expect(page).to have_select "Select group", selected: "All groups"
        expect(page).to have_css "div.expander[disabled]", text: "Subgroups"
        expect(page).to have_checked_field "No stage"
        expect(page).to have_css "span.tag-bar__tag", text: "No stage"
      end
    end
  end
end
