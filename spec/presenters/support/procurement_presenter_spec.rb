RSpec.describe Support::ProcurementPresenter do
  subject(:presenter) { described_class.new(procurement) }

  let(:procurement) { build(:support_procurement) }

  describe "#required_agreement_type" do
    context "when present" do
      it "returns the name of the agreement type" do
        expect(presenter.required_agreement_type).to eq "Ongoing"
      end
    end

    context "when nil" do
      let(:procurement) { build(:support_procurement, required_agreement_type: nil) }

      it "returns a hyphen" do
        expect(presenter.required_agreement_type).to eq "-"
      end
    end
  end

  describe "#route_to_market" do
    context "when present" do
      it "returns the name of the route to market" do
        expect(presenter.route_to_market).to eq "Bespoke Procurement"
      end
    end

    context "when nil" do
      let(:procurement) { build(:support_procurement, route_to_market: nil) }

      it "returns a hyphen" do
        expect(presenter.route_to_market).to eq "-"
      end
    end
  end

  describe "#reason_for_route_to_market" do
    context "when present" do
      it "returns the name of the reason for route to market" do
        expect(presenter.reason_for_route_to_market).to eq "School Preference"
      end
    end

    context "when nil" do
      let(:procurement) { build(:support_procurement, reason_for_route_to_market: nil) }

      it "returns a hyphen" do
        expect(presenter.reason_for_route_to_market).to eq "-"
      end
    end
  end

  describe "#stage" do
    context "when present" do
      it "returns the name of the procurement stage" do
        expect(presenter.stage).to eq "Need"
      end
    end

    context "when nil" do
      let(:procurement) { build(:support_procurement, stage: nil) }

      it "returns nil" do
        expect(presenter.stage).to be_nil
      end
    end
  end

  describe "#framework" do
    context "when present" do
      it "returns the framework presenter" do
        expect(presenter.framework).to be_a(Support::FrameworkPresenter)
      end
    end

    context "when nil" do
      let(:procurement) { build(:support_procurement, framework: nil) }

      it "returns nil" do
        expect(presenter.framework).to be_nil
      end
    end
  end

  describe "#framework_name" do
    context "when present" do
      it "returns the framework name" do
        expect(presenter.framework_name).to match(/Test framework \d+/)
      end
    end

    context "when nil" do
      let(:procurement) { build(:support_procurement, framework: nil) }

      it "returns a hyphen" do
        expect(presenter.framework_name).to eq "-"
      end
    end
  end

  describe "#started_at" do
    context "when present" do
      it "returns the start date in format %e %B %Y" do
        expect(presenter.started_at).to eq " 2 December 2020"
      end
    end

    context "when nil" do
      let(:procurement) { build(:support_procurement, started_at: nil) }

      it "returns a hyphen" do
        expect(presenter.started_at).to eq "-"
      end
    end
  end

  describe "#ended_at" do
    context "when present" do
      it "returns the end date in format %e %B %Y" do
        expect(presenter.ended_at).to eq " 1 December 2021"
      end
    end

    context "when nil" do
      let(:procurement) { build(:support_procurement, ended_at: nil) }

      it "returns a hyphen" do
        expect(presenter.ended_at).to eq "-"
      end
    end
  end
end
