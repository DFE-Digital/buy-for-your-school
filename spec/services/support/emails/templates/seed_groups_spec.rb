require "rails_helper"

describe Support::Emails::Templates::SeedGroups do
  subject(:service) { described_class.new }

  let(:groups) { Support::EmailTemplateGroup.where(parent_id: nil).order(title: :asc) }
  let(:sub_groups) { Support::EmailTemplateGroup.where.not(parent_id: nil).order(title: :asc) }

  it "populates the tables" do
    expect { service.call }
      .to change(groups, :count).from(0).to(7)
      .and change(sub_groups, :count).from(0).to(14)
  end

  context "when a group has sub-groups" do
    it "nests the sub-groups under the parent" do
      service.call

      energy = Support::EmailTemplateGroup.find_by(title: "Energy")
      sub_groups = energy.sub_groups.pluck(:title)
      solar_group = Support::EmailTemplateGroup.find_by(title: "Solar")

      expect(sub_groups).to include("Gas & Electricity")
      expect(sub_groups).to include("Audit")
      expect(solar_group.parent.title).to eq("Energy")
    end
  end
end
