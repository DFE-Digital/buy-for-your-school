require "rails_helper"

describe Support::Emails::Templates::Filter do
  subject(:service) { described_class.new }

  let(:group_energy) { create(:support_email_template_group, title: "Energy") }
  let(:subgroup_energy_solar) { create(:support_email_template_group, title: "Solar", parent: group_energy) }
  let(:subgroup_energy_gas) { create(:support_email_template_group, title: "Gas & Electricity", parent: group_energy) }
  let(:group_fm) { create(:support_email_template_group, title: "FM") }
  let(:subgroup_fm_catering) { create(:support_email_template_group, title: "Catering", parent: group_fm) }
  let(:subgroup_fm_cleaning) { create(:support_email_template_group, title: "Cleaning", parent: group_fm) }

  let!(:template_1) { create(:support_email_template, group: group_energy, stage: nil) }
  let!(:template_2) { create(:support_email_template, group: subgroup_energy_solar, stage: 1) }
  let!(:template_3) { create(:support_email_template, group: group_fm, stage: 2) }
  let!(:template_4) { create(:support_email_template, group: subgroup_fm_catering, stage: 4) }
  let!(:template_5) { create(:support_email_template, group: subgroup_fm_cleaning, stage: nil) }

  describe "#by_groups" do
    context "when filtering for all subgroups" do
      it "returns templates with all subgroups" do
        expect(service.by_groups(group_fm.id, subgroups: %w[all]).results).to match_array([template_3, template_4, template_5])
      end
    end

    context "when no subgroups specified" do
      it "returns templates with no subgroup" do
        expect(service.by_groups(group_energy.id).results).to match_array([template_1])
      end
    end

    context "when filtering for specific subgroups" do
      it "returns templates with matching subgroups" do
        expect(service.by_groups(group_fm.id, subgroups: [subgroup_fm_catering.id, subgroup_fm_cleaning.id]).results).to match_array([template_4, template_5])
      end
    end

    context "when filtering for specific subgroups and none" do
      it "returns templates with matching subgroups" do
        expect(service.by_groups(group_fm.id, subgroups: [subgroup_fm_catering.id, subgroup_fm_cleaning.id, "none"]).results).to match_array([template_3, template_4, template_5])
      end
    end
  end

  describe "#by_stages" do
    context "when filtering for all stages" do
      it "returns templates with all stages" do
        expect(service.by_stages(%w[all]).results).to match_array([template_1, template_2, template_3, template_4, template_5])
      end
    end

    context "when no stages specified" do
      it "returns templates with all stages" do
        expect(service.by_stages([]).results).to match_array([template_1, template_2, template_3, template_4, template_5])
      end
    end

    context "when filtering for specific stages" do
      it "returns templates with matching stages" do
        expect(service.by_stages(%w[2 4]).results).to match_array([template_3, template_4])
      end
    end

    context "when filtering for specific stages and none" do
      it "returns templates with matching stages" do
        expect(service.by_stages(%w[2 4 none]).results).to match_array([template_1, template_3, template_4, template_5])
      end
    end
  end
end
