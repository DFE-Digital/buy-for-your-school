require "rails_helper"

describe Support::SyncFrameworks do
  subject(:service) { described_class.new }

  let(:http_response) { nil }
  let(:testurl1) { "https://localhost:3000/nf1" }
  let(:testurl2) { "https://localhost:3000/nf2" }

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
            provider: { initials: "ABC", title: "ABC" },
            cat: { ref: "energy", title: "Energy" },
            ref: "ref-1",
            title: "Framework 1",
            expiry: "2026-08-31T00:00:00.000Z",
            url: testurl1,
            descr: "Desc",
          },
          {
            provider: { initials: "ABC", title: "ABC" },
            cat: { ref: "catering", title: "Catering" },
            ref: "ref-2",
            title: "Framework 2",
            expiry: "2026-06-30T00:00:00.000Z",
            url: testurl2,
            descr: "Desc",
          },
        ].to_json
      end

      before do
        allow(http_response).to receive(:body).and_return(body)
      end

      context "when there are frameworks to update" do
        let(:provider_detail) { create(:frameworks_provider, short_name: "ABC") }
        let!(:existing_framework) { create(:frameworks_framework, name: "Framework 1", provider_id: provider_detail.id, faf_slug_ref: "ref-1", faf_category: "Energy", provider_end_date: Date.parse("2025-11-15"), url: testurl1, description: "Desc", source: 2, status: "dfe_approved") }

        it "creates new frameworks and updates existing ones" do
          expect { service.call }.to change(Frameworks::Framework, :count).from(1).to(2)
            .and(change { existing_framework.reload.provider_end_date }.from(Date.parse("2025-11-15")).to(Date.parse("2026-08-31")))

          unchanged_attributes = %i[name provider_id faf_slug_ref faf_category url description source status]

          unchanged_attributes.each do |attribute|
            expect { existing_framework.reload }.to(not_change { existing_framework.send(attribute) })
          end

          new_framework = Frameworks::Framework.find_by(name: "Framework 2")
          expect(new_framework.provider_id).to eq(provider_detail.id)
          expect(new_framework.faf_slug_ref).to eq("ref-2")
          expect(new_framework.faf_category).to eq("Catering")
          expect(new_framework.provider_end_date).to eq(Date.parse("2026-06-30"))
          expect(new_framework.url).to eq(testurl2)
          expect(new_framework.source).to eq("faf_import")
          expect(new_framework.status).to eq("dfe_approved")
        end
      end

      context "when there are no frameworks to update" do
        let(:provider_detail) { create(:frameworks_provider, short_name: "ABC") }
        let!(:existing_framework1) { create(:frameworks_framework, name: "Framework 1", provider_id: provider_detail.id, faf_slug_ref: "ref-1", faf_category: "Energy", provider_end_date: Date.parse("2026-08-31"), url: testurl1, description: "Desc", source: 2, status: "dfe_approved") }
        let!(:existing_framework2) { create(:frameworks_framework, name: "Framework 2", provider_id: provider_detail.id, faf_slug_ref: "ref-2", faf_category: "Catering", provider_end_date: Date.parse("2026-06-30"), url: testurl2, description: "Desc", source: 2, status: "dfe_approved") }

        it "makes no changes to existing frameworks" do
          frameworks = [existing_framework1, existing_framework2]
          attributes = %i[name provider_id faf_slug_ref faf_category provider_end_date url description source status]

          expect { service.call }.to not_change(Frameworks::Framework, :count)

          frameworks.each do |framework|
            attributes.each do |attribute|
              expect { framework.reload }.to(not_change { framework.send(attribute) })
            end
          end
        end
      end

      context "when there ia a archived framework" do
        let(:provider_detail) { create(:frameworks_provider, short_name: "ABC") }
        let!(:existing_framework1) do
          create(
            :frameworks_framework,
            name: "Framework 3",
            provider_id: provider_detail.id,
            faf_slug_ref: "ref-1",
            faf_category: "Energy",
            provider_end_date: Date.parse("2026-08-31"),
            url: testurl1,
            description: "Desc",
            source: 2,
            status: "dfe_approved",
            faf_archived_at: Date.parse("2024-12-31"),
          )
        end

        it "makes no changes to existing frameworks" do
          expect { service.call }.to(not_change { existing_framework1.reload.faf_archived_at })
        end
      end
    end
  end
end
