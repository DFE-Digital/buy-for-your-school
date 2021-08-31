require "rails_helper"

RSpec.describe Support::BasePresenter do
  describe "#created_at" do
    it "returns a better formatted timestamp" do
      kase = Support::Case.find_by
      # kase = create(:case, created_at: '2021-12-01 00:00 BST')

      presenter = Support::CasePresenter.new(kase)
      expect(presenter.created_at).to eq(' 1 September 2021')
    end
  end

  describe "#updated_at" do
    it "returns a better formatted timestamp" do
      kase = Support::Case.find_by
      # kase = create(:case, updated_at: '2021-12-01 00:00 BST')

      presenter = Support::CasePresenter.new(kase)
      expect(presenter.updated_at).to eq(' 1 September 2021')
    end
  end
end
