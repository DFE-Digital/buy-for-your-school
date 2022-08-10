RSpec.describe ExitSurvey::OptInForm do
  subject(:form) { described_class.new(opt_in: "true") }

  describe "#data" do
    it "returns form values ready for persisting" do
      expect(form.data).to eql(
        opt_in: true,
      )
    end
  end
end
