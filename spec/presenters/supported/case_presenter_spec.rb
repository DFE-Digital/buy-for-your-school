require "rails_helper"

RSpec.describe Support::CasePresenter do
  describe "#state" do
    it "returns an upcase state" do
      kase = Support::Case.find_by
      # kase = create(:case, state: 'new')

      presenter = described_class.new(kase)
      expect(presenter.state).to eq('NEW')
    end
  end
end
