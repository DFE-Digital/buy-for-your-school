RSpec.describe ExitSurvey::HearAboutServiceForm do
  subject(:form) { described_class.new(hear_about_service: "dfe_event", hear_about_service_other: "elsewhere") }

  describe "#data" do
    context "when hear_about_service is 'other'" do
      subject(:form) { described_class.new(hear_about_service: "other", hear_about_service_other: "elsewhere") }

      it "returns form values ready for persisting" do
        expect(form.data).to eql(
          hear_about_service: :other,
          hear_about_service_other: "elsewhere",
        )
      end
    end

    context "when hear_about_service is not 'other'" do
      it "nullifies the 'other' value" do
        expect(form.data).to eql(
          hear_about_service: :dfe_event,
          hear_about_service_other: nil,
        )
      end
    end
  end

  describe "#hear_about_service_options" do
    it "returns the hear_about_service options" do
      expect(form.hear_about_service_options).to eq %w[dfe_email dfe_event non_dfe_event dfe_promotion other_dfe_service_referral online_search social_media word_of_mouth other]
    end
  end
end
