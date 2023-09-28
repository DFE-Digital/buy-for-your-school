require "rails_helper"

describe Frameworks::Framework::ActivityLogPresentable do
  subject(:presentable) { Frameworks::Framework.new }

  describe "#specific_change_template_for" do
    it "returns nil by default" do
      template = presentable.specific_change_template_for(Frameworks::ActivityLoggableVersion.new(object_changes: {}))
      expect(template).to be_nil
    end

    context "when the only changes are to the status field" do
      it "returns frameworks/status" do
        template = presentable.specific_change_template_for(Frameworks::ActivityLoggableVersion.new(object_changes: { status: [] }))
        expect(template).to eq("frameworks/status")
      end
    end
  end
end
