require "rails_helper"

describe Frameworks::ActivityLoggableVersion do
  context "when the item is being created" do
    it "also records the default fields added by enums, db etc" do
      framework = create(:frameworks_framework)
      expect(framework.versions.last.object_changes.keys).to include("reference") # added by db
      expect(framework.versions.last.object_changes.keys).to include("status")    # default enum value
    end
  end
end
