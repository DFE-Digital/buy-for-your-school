require "rails_helper"

describe Support::EmailTemplateGroup, type: :model do
  it { is_expected.to belong_to(:parent).class_name("Support::EmailTemplateGroup").optional }
  it { is_expected.to have_many(:templates).class_name("Support::EmailTemplate").with_foreign_key("template_group_id") }
  it { is_expected.to have_many(:sub_groups).class_name("Support::EmailTemplateGroup").with_foreign_key("parent_id") }

  describe ".top_level" do
    before do
      group_1 = create(:support_email_template_group, title: "Parent Group 1")
      group_2 = create(:support_email_template_group, title: "Parent Group 2")
      create(:support_email_template_group, title: "Sub-Group 1", parent: group_1)
      create(:support_email_template_group, title: "Sub-Group 2", parent: group_2)
    end

    it "returns all groups without a parent" do
      top_level_groups = described_class.top_level
      expect(top_level_groups.size).to eq(2)
      expect(top_level_groups.pluck(:title)).to eq(["Parent Group 1", "Parent Group 2"])
    end
  end

  describe "#hierarchy" do
    let(:group) { create(:support_email_template_group, title: "Group") }
    let(:subgroup) { create(:support_email_template_group, title: "Sub-Group", parent: group) }
    let(:subsubgroup) { create(:support_email_template_group, title: "Sub-Sub-Group", parent: subgroup) }

    it "returns the group hierarchy" do
      expect(subsubgroup.hierarchy).to eq([group, subgroup, subsubgroup])
    end
  end

  describe "#is_top_level?" do
    context "when the group is top-level" do
      let(:group) { create(:support_email_template_group, title: "Group") }

      it "returns true" do
        expect(group.is_top_level?).to eq(true)
      end
    end

    context "when the group is not top-level" do
      let(:group) { create(:support_email_template_group, title: "Group", parent: create(:support_email_template_group)) }

      it "returns false" do
        expect(group.is_top_level?).to eq(false)
      end
    end
  end
end
