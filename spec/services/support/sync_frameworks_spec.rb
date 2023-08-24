require "rails_helper"

describe Support::SyncFrameworks do
  subject(:service) { described_class.new }

  let(:http_response) { nil }

  before do
    http = double("http")
    allow(Net::HTTP).to receive(:start).and_yield(http)
    allow(http).to receive(:request).with(an_instance_of(Net::HTTP::Get)).and_return(http_response)
  end

  describe "#call" do
    context "when the request is authorized" do
      let(:http_response) { Net::HTTPSuccess.new(1.0, "200", "OK") }
      let(:body) do
        [
          {
            provider: { initials: "P1", title: "Provider 1" },
            cat: { ref: "energy", title: "Energy" },
            ref: "f1",
            title: "Framework 1",
            expiry: "2020-08-31T00:00:00.000Z",
          },
          {
            provider: { initials: "P2", title: "Provider 2" },
            cat: { ref: "catering", title: "Catering" },
            ref: "f2",
            title: "Framework 2",
            expiry: "2020-06-30T00:00:00.000Z",
          },
        ].to_json
      end

      before do
        allow(http_response).to receive(:body).and_return(body)
      end

      context "when there are frameworks to update" do
        let!(:existing_framework) { create(:support_framework, name: "Framework 1", supplier: "P1", category: "Energy", ref: "f1", expires_at: Date.parse("2020-01-15")) }

        it "creates new frameworks and updates existing ones" do
          expect { service.call }.to change(Support::Framework, :count).from(1).to(2)
            .and(change { existing_framework.reload.expires_at }.from(Date.parse("2020-01-15")).to(Date.parse("2020-08-31")))
            .and(not_change { existing_framework.reload.name })
            .and(not_change { existing_framework.reload.supplier })
            .and(not_change { existing_framework.reload.category })

          new_framework = Support::Framework.find_by(name: "Framework 2")
          expect(new_framework.supplier).to eq("P2")
          expect(new_framework.category).to eq("Catering")
          expect(new_framework.expires_at).to eq(Date.parse("2020-06-30"))
        end
      end

      context "when there are no frameworks to update" do
        let!(:existing_framework1) { create(:support_framework, name: "Framework 1", supplier: "P1", category: "Energy", ref: "f1", expires_at: Date.parse("2020-08-31")) }
        let!(:existing_framework2) { create(:support_framework, name: "Framework 2", supplier: "P2", category: "Catering", ref: "f2", expires_at: Date.parse("2020-06-30")) }

        it "makes no changes to existing frameworks" do
          expect { service.call }.to not_change(Support::Framework, :count)
          .and(not_change { existing_framework1.reload.name })
          .and(not_change { existing_framework1.reload.supplier })
          .and(not_change { existing_framework1.reload.category })
          .and(not_change { existing_framework1.reload.expires_at })
          .and(not_change { existing_framework2.reload.name })
          .and(not_change { existing_framework2.reload.supplier })
          .and(not_change { existing_framework2.reload.category })
          .and(not_change { existing_framework2.reload.expires_at })
        end
      end

      it "converts the support frameworks into the framework register records" do
        expect { service.call }.to change(Frameworks::Framework, :count).from(0).to(2)
      end
    end
  end
end
