require "school/information"

RSpec.describe School::Information, "#call" do
  include_context "with gias data"

  before do
    create(:support_organisation, urn: "106653", name: "Penistone Grammar School", local_authority: create(:local_authority, la_code: "370", name: "Barnsley"))
    create(:support_organisation, urn: "126416", name: "St Thomas à Becket Church of England Aided Primary School", local_authority: create(:local_authority, la_code: "865", name: "Wiltshire"))
    create(:support_organisation, urn: "117137", name: "Fleetville Junior School", local_authority: create(:local_authority, la_code: "919", name: "Hertfordshire"))
    create(:support_organisation, urn: "123456", name: "School Not In Import", local_authority: create(:local_authority, la_code: "123", name: "Lancashire"))
    create(:local_authority, la_code: "111", name: "Camden")
  end

  context "with no file" do
    subject(:service) { described_class.new }

    before do
      travel_to Time.zone.local(2004, 11, 24, 0o1, 0o4, 44)

      stub_request(:get, "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata20041124.csv").to_return(body: "")
    end

    it "downloads the current GIAS CSV data" do
      expect(service.call).to eql []
    end

    context "and an exporter" do
      subject(:service) { described_class.new(exporter:) }

      let(:exporter) { ->(x) { x } }

      it "calls the exporter using the formatted data" do
        allow(exporter).to receive(:call).with([]).and_return([])

        service.call
      end
    end
  end

  context "when the file is a File" do
    subject(:service) { described_class.new(file:) }

    let(:file) { File.open(gias_data) }

    it "outputs formatted data from the local source" do
      output = service.call.map { |s| s[:school][:name] }

      expect(output).to eql [
        "Penistone Grammar School",
        "St Thomas à Becket Church of England Aided Primary School",
        "Fleetville Junior School",
      ]
    end
  end

  context "when the file is a String" do
    subject(:service) { described_class.new(file: gias_data) }

    it "loads the file" do
      expect(service.file.path).to eql gias_data
    end

    it "outputs formatted data from the local source" do
      output = service.call.map { |s| s[:ukprn] }

      expect(output).to eql [10_005_034, 10_076_257, ""]

      expect(Support::Organisation.count).to be 4
      expect(Support::Organisation.where(urn: "106653").first.archived).to eq(false)
      expect(Support::Organisation.where(urn: "106653").first.archived_at).to eq(nil)
      expect(Support::Organisation.where(urn: "123456").first.archived).to eq(true)
      expect(Support::Organisation.where(urn: "123456").first.archived_at).to be_within(1.second).of(Time.zone.now)

      expect(LocalAuthority.count).to be 5
      expect(LocalAuthority.where(la_code: "370").first.archived).to eq(false)
      expect(LocalAuthority.where(la_code: "370").first.archived_at).to eq(nil)
      expect(LocalAuthority.where(la_code: "111").first.archived).to eq(true)
      expect(LocalAuthority.where(la_code: "111").first.archived_at).to be_within(1.second).of(Time.zone.now)
    end
  end
end
