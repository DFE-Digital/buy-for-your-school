require "rails_helper"

describe Support::CaseContactPresenter do
  subject(:presenter) { described_class.new(build(:support_case)) }

  describe "#first_name" do
    context "when first_name and last_name are both blank" do
      before do
        presenter.first_name = ""
        presenter.last_name = ""
      end

      it "returns 'Sir'" do
        expect(presenter.first_name).to eq("Sir")
      end
    end

    context "when first_name is present" do
      before do
        presenter.first_name = "Test"
        presenter.last_name = ""
      end

      it "returns 'Sir'" do
        expect(presenter.first_name).to eq("Test")
      end
    end
  end

  describe "#last_name" do
    context "when first_name is present but last_name is blank" do
      before do
        presenter.first_name = "Test"
        presenter.last_name = ""
      end

      it "returns an empty string" do
        expect(presenter.last_name).to eq("")
      end
    end

    context "when first_name and last_name is blank" do
      before do
        presenter.first_name = ""
        presenter.last_name = ""
      end

      it "returns 'or Madam'" do
        expect(presenter.last_name).to eq("or Madam")
      end
    end

    context "when first_name is blank but last_name is present" do
      before do
        presenter.first_name = ""
        presenter.last_name = "Tester"
      end

      it "returns 'or Madam'" do
        expect(presenter.last_name).to eq("or Madam")
      end
    end

    context "when first_name and last_name are present" do
      before do
        presenter.first_name = "Frank"
        presenter.last_name = "Tester"
      end

      it "returns the last_name" do
        expect(presenter.last_name).to eq("Tester")
      end
    end
  end
end
