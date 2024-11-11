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
        let(:provider) { create(:frameworks_provider, short_name: "ABC") }
        let!(:existing_framework) { create(:frameworks_framework, name: "Framework 1", provider_id: provider.id, faf_slug_ref: "ref-1", faf_category: "Energy", provider_end_date: Date.parse("2025-11-15"), url: "https://localhost:3000/nf1", description: "Desc", source: 2, status: "dfe_approved") }

        it "creates new frameworks and updates existing ones" do
          expect { service.call }.to change(Frameworks::Framework, :count).from(1).to(3)
            .and(change { existing_framework.reload.provider_end_date }.from(Date.parse("2025-11-15")).to(Date.parse("2026-11-15")))
            .and(not_change { existing_framework.reload.name })
            .and(not_change { existing_framework.reload.provider_id })
            .and(not_change { existing_framework.reload.faf_slug_ref })
            .and(not_change { existing_framework.reload.faf_category })
            .and(not_change { existing_framework.reload.url })
            .and(not_change { existing_framework.reload.description })
            .and(not_change { existing_framework.reload.source })

          new_framework = Frameworks::Framework.find_by(name: "Framework 2")
          expect(new_framework.provider_id).to eq(provider.id)
          expect(new_framework.faf_slug_ref).to eq("ref-2")
          expect(new_framework.faf_category).to eq("Catering")
          expect(new_framework.provider_end_date).to eq(Date.parse("2020-06-30"))
          expect(new_framework.url).to eq("https://localhost:3000/nf2")
          expect(new_framework.source).to eq(2)
          expect(new_framework.status).to eq("dfe_approved")
        end
      end

      context "when there are no frameworks to update" do
        let(:provider) { create(:frameworks_provider, short_name: "XYZ") }
        let!(:existing_framework1) { create(:frameworks_framework, name: "Framework 1", provider_id: provider.id, faf_slug_ref: "ref-1", faf_category: "Energy", provider_end_date: Date.parse("2025-11-15"), url: "https://localhost:3000/nf1", description: "Desc", source: 2, status: "dfe_approved") }
        let!(:existing_framework2) { create(:frameworks_framework, name: "Framework 2", provider_id: provider.id, faf_slug_ref: "ref-2", faf_category: "Catering", provider_end_date: Date.parse("2025-11-15"), url: "https://localhost:3000/nf2", description: "Desc", source: 2, status: "dfe_approved") }

        it "makes no changes to existing frameworks" do
          expect { service.call }.to change(Frameworks::Framework, :count).from(2).to(4)
          .and(not_change { existing_framework1.reload.name })
          .and(not_change { existing_framework1.reload.provider_id })
          .and(not_change { existing_framework1.reload.faf_slug_ref })
          .and(not_change { existing_framework1.reload.faf_category })
          .and(not_change { existing_framework1.reload.provider_end_date })
          .and(not_change { existing_framework1.reload.url })
          .and(not_change { existing_framework1.reload.description })
          .and(not_change { existing_framework1.reload.source })
          .and(not_change { existing_framework2.reload.name })
          .and(not_change { existing_framework2.reload.provider_id })
          .and(not_change { existing_framework2.reload.faf_slug_ref })
          .and(not_change { existing_framework2.reload.faf_category })
          .and(not_change { existing_framework2.reload.provider_end_date })
          .and(not_change { existing_framework2.reload.url })
          .and(not_change { existing_framework2.reload.description })
          .and(not_change { existing_framework2.reload.source })
        end
      end
    end
  end
end
