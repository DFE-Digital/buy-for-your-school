require "rails_helper"

describe Support::SyncFrameworks do
  subject(:service) { described_class.new }

  let(:http_response) { nil }
  let(:testurl1) { "https://localhost:3000/nf1" }
  let(:testurl2) { "https://localhost:3000/nf2" }
  let(:contentful_id_1) { "contentful-id-1" }
  let(:contentful_id_2) { "contentful-id-2" }
  let(:framework_1_expiry) { "2026-08-31" }
  let(:framework_2_expiry) { "2026-06-30" }
  let(:old_expiry_date) { "2025-11-15" }
  let(:framework_1_name) { "Framework 1" }
  let(:framework_2_name) { "Framework 2" }

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
            id: contentful_id_1,
            provider: { initials: "ABC", title: "ABC" },
            cat: { ref: "energy", title: "Energy" },
            ref: "ref-1",
            title: framework_1_name,
            expiry: "2026-08-31T00:00:00.000Z",
            url: testurl1,
            descr: "Desc",
            provider_reference: "PR-1",
          },
          {
            id: contentful_id_2,
            provider: { initials: "ABC", title: "ABC" },
            cat: { ref: "catering", title: "Catering" },
            ref: "ref-2",
            title: framework_2_name,
            expiry: "2026-06-30T00:00:00.000Z",
            url: testurl2,
            descr: "Desc",
            provider_reference: "PR-2",
          },
        ].to_json
      end

      before do
        allow(http_response).to receive(:body).and_return(body)
      end

      context "when there are frameworks to update" do
        let(:provider_detail) { create(:frameworks_provider, short_name: "ABC") }
        let!(:existing_framework) { create(:frameworks_framework, name: framework_1_name, provider_id: provider_detail.id, faf_slug_ref: "ref-1", faf_category: "Energy", provider_end_date: Date.parse(old_expiry_date), url: testurl1, description: "Desc", source: 2, status: "dfe_approved") }

        it "creates new frameworks and updates existing ones" do
          expect { service.call }.to change(Frameworks::Framework, :count).from(1).to(2)
            .and(change { existing_framework.reload.provider_end_date }.from(Date.parse(old_expiry_date)).to(Date.parse(framework_1_expiry)))
            .and(change { existing_framework.reload.contentful_id }.from(nil).to(contentful_id_1))

          unchanged_attributes = %i[name provider_id faf_slug_ref faf_category url description source status]

          unchanged_attributes.each do |attribute|
            expect { existing_framework.reload }.to(not_change { existing_framework.send(attribute) })
          end

          new_framework = Frameworks::Framework.find_by(name: framework_2_name)
          expect(new_framework.provider_id).to eq(provider_detail.id)
          expect(new_framework.contentful_id).to eq(contentful_id_2)
          expect(new_framework.faf_slug_ref).to eq("ref-2")
          expect(new_framework.faf_category).to eq("Catering")
          expect(new_framework.provider_end_date).to eq(Date.parse(framework_2_expiry))
          expect(new_framework.url).to eq(testurl2)
          expect(new_framework.source).to eq("faf_import")
          expect(new_framework.status).to eq("dfe_approved")
          expect(new_framework.provider_reference).to eq("PR-2")
        end
      end

      context "when a new solution is created in Contentful" do
        let(:provider_detail) { create(:frameworks_provider, short_name: "ABC") }
        let(:body_new_framework) do
          [
            {
              id: contentful_id_1,
              provider: { initials: "ABC", title: "ABC" },
              cat: { ref: "energy", title: "Energy" },
              ref: "ref-1",
              title: framework_1_name,
              expiry: "2026-08-31T00:00:00.000Z",
              url: testurl1,
              descr: "Desc",
              provider_reference: "PR-1",
            },
          ].to_json
        end

        before do
          allow(http_response).to receive(:body).and_return(body_new_framework)
        end

        it "creates activity log with creation date of today and contentful_id in created event" do
          expect { service.call }.to change(Frameworks::Framework, :count).from(0).to(1)

          new_framework = Frameworks::Framework.find_by(contentful_id: contentful_id_1)
          expect(new_framework).to be_present

          activity_log_item = Frameworks::ActivityLogItem.where(subject: new_framework).first
          expect(activity_log_item).to be_present
          expect(activity_log_item.created_at.to_date).to eq(Time.zone.today)

          version = activity_log_item.activity
          expect(version.event).to eq("create")
          expect(version.object_changes).to include("contentful_id")
          expect(version.object_changes["contentful_id"]).to eq([nil, contentful_id_1])
        end
      end

      context "when there are no frameworks to update" do
        let(:provider_detail) { create(:frameworks_provider, short_name: "ABC") }
        let!(:existing_framework1) { create(:frameworks_framework, name: framework_1_name, provider_id: provider_detail.id, contentful_id: contentful_id_1, faf_slug_ref: "ref-1", faf_category: "Energy", provider_end_date: Date.parse(framework_1_expiry), url: testurl1, description: "Desc", source: 2, status: "dfe_approved") }
        let!(:existing_framework2) { create(:frameworks_framework, name: framework_2_name, provider_id: provider_detail.id, contentful_id: contentful_id_2, faf_slug_ref: "ref-2", faf_category: "Catering", provider_end_date: Date.parse(framework_2_expiry), url: testurl2, description: "Desc", source: 2, status: "dfe_approved") }

        it "makes no changes to existing frameworks" do
          frameworks = [existing_framework1, existing_framework2]
          attributes = %i[name provider_id faf_slug_ref faf_category provider_end_date url description source status contentful_id]

          expect { service.call }.to not_change(Frameworks::Framework, :count)

          frameworks.each do |framework|
            attributes.each do |attribute|
              expect { framework.reload }.to(not_change { framework.send(attribute) })
            end
          end
        end
      end

      context "when matching by contentful_id" do
        let(:provider_detail) { create(:frameworks_provider, short_name: "ABC") }
        let(:body_single_framework) do
          [
            {
              id: contentful_id_1,
              provider: { initials: "ABC", title: "ABC" },
              cat: { ref: "energy", title: "Energy" },
              ref: "ref-1",
              title: framework_1_name,
              expiry: "2026-08-31T00:00:00.000Z",
              url: testurl1,
              descr: "Desc",
              provider_reference: "PR-1",
            },
          ].to_json
        end
        let!(:existing_framework) do
          create(:frameworks_framework,
                 name: "Old Framework Name",
                 provider_id: provider_detail.id,
                 contentful_id: contentful_id_1,
                 faf_slug_ref: "ref-1",
                 faf_category: "Energy",
                 provider_end_date: Date.parse(old_expiry_date),
                 url: testurl1,
                 description: "Desc",
                 source: 2,
                 status: "dfe_approved")
        end

        before do
          allow(http_response).to receive(:body).and_return(body_single_framework)
        end

        it "matches by contentful_id even when name has changed" do
          expect { service.call }.to not_change(Frameworks::Framework, :count)

          existing_framework.reload
          expect(existing_framework.name).to eq(framework_1_name) # name updated from API
          expect(existing_framework.contentful_id).to eq(contentful_id_1) # still the same
          expect(existing_framework.provider_end_date).to eq(Date.parse(framework_1_expiry))
        end

        context "when solution is renamed in Contentful" do
          it "creates activity log showing name change" do
            activity_logs_before = Frameworks::ActivityLogItem.where(subject: existing_framework).count

            service.call

            existing_framework.reload
            activity_logs_after = Frameworks::ActivityLogItem.where(subject: existing_framework).count
            expect(activity_logs_after).to eq(activity_logs_before + 1)

            activity_log_item = Frameworks::ActivityLogItem.where(subject: existing_framework).order(created_at: :desc).first
            version = activity_log_item.activity

            expect(version.event).to eq("update")
            expect(version.object_changes).to include("name")
            expect(version.object_changes["name"]).to eq(["Old Framework Name", framework_1_name])
            expect(activity_log_item.created_at.to_date).to eq(Time.zone.today)
          end
        end
      end

      context "when framework is archived in FABS" do
        let(:provider_detail) { create(:frameworks_provider, short_name: "ABC") }
        let!(:existing_framework) do
          create(:frameworks_framework,
                 name: "Framework 3",
                 provider_id: provider_detail.id,
                 contentful_id: "contentful-id-3",
                 faf_slug_ref: "ref-3",
                 faf_category: "Energy",
                 provider_end_date: Date.parse(framework_1_expiry),
                 url: testurl1,
                 description: "Desc",
                 source: 2,
                 status: "dfe_approved",
                 faf_archived_at: nil)
        end

        it "archives framework not in API response" do
          # API returns Framework 1 & 2, but not Framework 3 - so 3 should be archived
          expect { service.call }.to change { existing_framework.reload.is_archived }.from(false).to(true)
            .and(change { existing_framework.reload.status }.from("dfe_approved").to("archived"))
            .and(change { existing_framework.reload.faf_archived_at }.from(nil))
        end

        context "when solution is expired in Contentful" do
          it "creates activity log showing framework archived" do
            activity_logs_before = Frameworks::ActivityLogItem.where(subject: existing_framework).count

            service.call

            existing_framework.reload
            activity_logs_after = Frameworks::ActivityLogItem.where(subject: existing_framework).count
            expect(activity_logs_after).to be > activity_logs_before

            activity_log_item = Frameworks::ActivityLogItem.where(subject: existing_framework).order(created_at: :desc).first
            version = activity_log_item.activity

            expect(version.event).to eq("update")
            expect(version.object_changes).to include("status")
            expect(version.object_changes["status"]).to eq(%w[dfe_approved archived])
            expect(version.object_changes).to include("is_archived")
            expect(version.object_changes["is_archived"]).to eq([false, true])
            expect(activity_log_item.created_at.to_date).to eq(Time.zone.today)
          end
        end
      end

      context "when there is an archived framework" do
        let(:provider_detail) { create(:frameworks_provider, short_name: "ABC") }
        let!(:existing_framework1) do
          create(
            :frameworks_framework,
            name: "Framework 3",
            provider_id: provider_detail.id,
            faf_slug_ref: "ref-1",
            faf_category: "Energy",
            provider_end_date: Date.parse(framework_1_expiry),
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

      context "when solution is created with same name as existing CMS record (without contentful_id)" do
        let(:provider_detail) { create(:frameworks_provider, short_name: "ABC") }
        let!(:legacy_framework) do
          create(:frameworks_framework,
                 name: framework_1_name,
                 provider_id: provider_detail.id,
                 contentful_id: nil, # Legacy record without contentful_id
                 faf_slug_ref: "ref-1",
                 faf_category: "Energy",
                 provider_end_date: Date.parse(old_expiry_date),
                 url: testurl1,
                 description: "Desc",
                 source: 2,
                 status: "dfe_approved")
        end
        let(:body_single_framework) do
          [
            {
              id: contentful_id_1,
              provider: { initials: "ABC", title: "ABC" },
              cat: { ref: "energy", title: "Energy" },
              ref: "ref-1",
              title: framework_1_name, # Same name as legacy_framework
              expiry: "2026-08-31T00:00:00.000Z",
              url: testurl1,
              descr: "Desc",
              provider_reference: "PR-1",
            },
          ].to_json
        end

        before do
          allow(http_response).to receive(:body).and_return(body_single_framework)
        end

        it "matches legacy record by name+provider and populates contentful_id (does not create duplicate)" do
          expect { service.call }.to not_change(Frameworks::Framework, :count)

          legacy_framework.reload
          expect(legacy_framework.contentful_id).to eq(contentful_id_1)
          expect(legacy_framework.name).to eq(framework_1_name)
          expect(legacy_framework.provider_end_date).to eq(Date.parse(framework_1_expiry))
        end
      end

      context "when new solution is created with same name as expired/archived framework" do
        let(:provider_detail) { create(:frameworks_provider, short_name: "ABC") }
        let!(:archived_framework) do
          create(:frameworks_framework,
                 name: framework_1_name,
                 provider_id: provider_detail.id,
                 contentful_id: "old-contentful-id",
                 faf_slug_ref: "ref-1",
                 faf_category: "Energy",
                 provider_end_date: Date.parse("2024-01-01"), # Expired
                 url: testurl1,
                 description: "Desc",
                 source: 2,
                 status: "archived",
                 is_archived: true,
                 faf_archived_at: Date.parse("2024-12-31"))
        end
        let(:body_new_framework) do
          [
            {
              id: contentful_id_1, # Different contentful_id
              provider: { initials: "ABC", title: "ABC" },
              cat: { ref: "energy", title: "Energy" },
              ref: "ref-1",
              title: framework_1_name, # Same name as archived_framework
              expiry: "2026-08-31T00:00:00.000Z",
              url: testurl1,
              descr: "Desc",
              provider_reference: "PR-1",
            },
          ].to_json
        end

        before do
          allow(http_response).to receive(:body).and_return(body_new_framework)
        end

        it "creates new framework instead of updating archived one" do
          expect { service.call }.to change(Frameworks::Framework, :count).from(1).to(2)

          # Archived framework should remain unchanged
          archived_framework.reload
          expect(archived_framework.contentful_id).to eq("old-contentful-id")
          expect(archived_framework.status).to eq("archived")
          expect(archived_framework.is_archived).to be(true)

          # New framework should be created
          new_framework = Frameworks::Framework.find_by(contentful_id: contentful_id_1)
          expect(new_framework).to be_present
          expect(new_framework.name).to eq(framework_1_name)
          expect(new_framework.provider_id).to eq(provider_detail.id)
          expect(new_framework.status).to eq("dfe_approved")
          expect(new_framework.is_archived).to be(false)
        end
      end
    end
  end
end
