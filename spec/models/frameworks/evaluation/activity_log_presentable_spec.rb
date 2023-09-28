require "rails_helper"

describe Frameworks::Evaluation::ActivityLogPresentable do
  subject(:presentable) { Frameworks::Evaluation.new }

  describe "#specific_change_template_for" do
    it "returns nil by default" do
      template = presentable.specific_change_template_for(Frameworks::ActivityLoggableVersion.new(object_changes: {}))
      expect(template).to be_nil
    end

    context "when the only changes are to the status field" do
      it "returns evaluations/status" do
        template = presentable.specific_change_template_for(Frameworks::ActivityLoggableVersion.new(object_changes: { status: [] }))
        expect(template).to eq("evaluations/status")
      end
    end
  end
end
