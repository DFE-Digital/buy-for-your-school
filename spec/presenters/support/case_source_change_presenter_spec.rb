RSpec.describe Support::CaseSourceChangePresenter do
  subject(:presenter) { described_class.new(interaction) }

  let(:agent) { create(:support_agent, first_name: "CMS", last_name: "User") }
  let(:interaction) { create(:support_interaction, :case_source_changed, agent:, additional_data: { from: "incoming_email", to: "faf" }) }

  describe "#body" do
    it "tells what the source changed from and to and who made the change" do
      expect(presenter.body).to eq "CMS User changed source from Email to Find a Framework"
    end
  end
end
