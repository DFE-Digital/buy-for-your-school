RSpec.describe ExitSurvey::OptInDetailForm do
  subject(:form) { described_class.new(opt_in_name: "name", opt_in_email: "email") }

  describe "#data" do
    it "returns form values ready for persisting" do
      expect(form.data).to eql(
        opt_in_name: "name",
        opt_in_email: "email",
      )
    end
  end
end
