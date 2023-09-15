require "rails_helper"

describe Frameworks::ActivityLoggable do
  describe "on create" do
    it "creates an activity log item with the PaperTrail::Version changes enclosed" do
      provider = Frameworks::Provider.new(short_name: "TestProv")

      expect { provider.save! }.to change(Frameworks::ActivityLogItem, :count).from(0).to(1)

      activity_log_item = Frameworks::ActivityLogItem.where(subject: provider).reorder("created_at ASC").first
      expect(provider.versions.count).to eq(1)
      expect(activity_log_item.activity).to eq(provider.versions.last)
    end
  end

  describe "on update" do
    it "creates an activity log item with the PaperTrail::Version changes enclosed" do
      provider = Frameworks::Provider.create!(short_name: "TestProv")

      expect { provider.update(short_name: "TestProvider") }.to change(Frameworks::ActivityLogItem, :count).from(1).to(2)

      activity_log_item = Frameworks::ActivityLogItem.where(subject: provider).reorder("created_at ASC").last
      expect(provider.versions.count).to eq(2)
      expect(activity_log_item.activity).to eq(provider.versions.last)
    end
  end
end
