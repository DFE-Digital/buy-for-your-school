require "rails_helper"

describe Support::EmailTemplate, type: :model do
  it { is_expected.to belong_to(:group).class_name("Support::EmailTemplateGroup").with_foreign_key("template_group_id") }
  it { is_expected.to belong_to(:created_by).class_name("Support::Agent") }
  it { is_expected.to belong_to(:updated_by).class_name("Support::Agent").optional }
  it { is_expected.to have_many(:emails).class_name("Support::Email").with_foreign_key("template_id") }
  it { is_expected.to validate_inclusion_of(:stage).in_array([0, 1, 2, 3, 4]).allow_nil }

  describe "default ordering" do
    before do
      create(:support_email_template, title: "D template")
      create(:support_email_template, title: "C template")
      create(:support_email_template, title: "A template")
      create(:support_email_template, title: "B template")
    end

    it "orders in ascending alphabetical order" do
      expect(described_class.all.pluck(:title)).to eq ["A template", "B template", "C template", "D template"]
    end
  end

  describe ".active" do
    before do
      create(:support_email_template, title: "D template")
      create(:support_email_template, title: "C template", archived: true)
      create(:support_email_template, title: "A template")
      create(:support_email_template, title: "B template")
    end

    it "returns active templates in ascending alphabetical order" do
      expect(described_class.active.pluck(:title)).to eq ["A template", "B template", "D template"]
    end
  end

  describe ".stages" do
    it "returns all possible stages" do
      expect(described_class.stages).to eq([0, 1, 2, 3, 4])
    end
  end

  describe "#archive!" do
    let(:old_agent) { create(:support_agent) }
    let(:new_agent) { create(:support_agent) }
    let(:template) { create(:support_email_template, updated_by: old_agent) }

    context "when no agent is provided" do
      it "archives the template without changing updated_by" do
        expect { template.archive! }.to change(template, :archived).from(false).to(true)
          .and change(template, :archived_at).from(nil).to(be_within(1.second).of(Time.zone.now))
          .and not_change(template, :updated_by)
      end
    end

    context "when an agent is provided" do
      it "archives the template and changes updated_by" do
        expect { template.archive!(new_agent) }.to change(template, :archived).from(false).to(true)
          .and change(template, :archived_at).from(nil).to(be_within(1.second).of(Time.zone.now))
          .and change(template, :updated_by).from(old_agent).to(new_agent)
      end
    end
  end
end
