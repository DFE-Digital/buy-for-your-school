describe Support::CaseWithSchoolChangePresenter do
  subject(:presenter) { described_class.new(interaction) }

  let(:agent) { create(:support_agent, first_name: "CMS", last_name: "User") }
  let(:to) { true }
  let(:interaction) { create(:support_interaction, :case_with_school_changed, agent:, additional_data: { from: false, to: }) }

  describe "#body" do
    context "when the flag is set" do
      let(:to) { true }

      it "tells who set it" do
        expect(presenter.body).to eq "CMS User set the 'With School' flag"
      end
    end

    context "when the flag is cleared" do
      let(:to) { false }

      it "tells who cleared it" do
        expect(presenter.body).to eq "CMS User cleared the 'With School' flag"
      end
    end

    context "when changed by the system" do
      let(:agent) { nil }

      let(:to) { false }

      it "tells the system cleared it" do
        expect(presenter.body).to eq "The 'With School' flag was cleared by the system"
      end
    end
  end

  describe "#show_additional_data?" do
    it "returns false" do
      expect(presenter.show_additional_data?).to eq(false)
    end
  end
end
