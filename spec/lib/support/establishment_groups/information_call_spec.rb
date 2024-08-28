require "support/establishment_groups/information"

RSpec.describe Support::EstablishmentGroups::Information, "#call" do
  include_context "with establishment group data"

  before do
    create(:support_establishment_group, uid: "1000", name: "Federation of Schools")
    create(:support_establishment_group, uid: "1234", name: "Org Not In Import")
  end

  context "with no file" do
    subject(:service) { described_class.new }

    before do
      travel_to Time.zone.local(2004, 11, 24, 0o1, 0o4, 44)

      stub_request(:get, "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/allgroupsdata20041124.csv").to_return(body: "")
    end

    it "downloads the current GIAS establishment groups CSV data" do
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

    let(:file) { File.open(establishment_group_data) }

    it "outputs formatted data from the local source" do
      output = service.call.map { |eg| eg[:name] }

      expect(output).to eql [
        "Federation of Schools",
        "Single-academy Trust School",
        "Multi-Academy trust Schools",
        "Trust Schools",
        "Sponsored School",
        "Umbrella trust schools",
      ]
    end
  end

  context "when the file is a String" do
    subject(:service) { described_class.new(file: establishment_group_data) }

    it "loads the file" do
      expect(service.file.path).to eql establishment_group_data
    end

    it "outputs formatted data from the local source" do
      output = service.call.map { |eg| eg[:ukprn] }

      expect(output).to eql %w[1010101 1010102 1010103 1010104 1010105 1010106]

      expect(Support::EstablishmentGroup.count).to be 2
      expect(Support::EstablishmentGroup.where(uid: "1000").first.archived).to eq(false)
      expect(Support::EstablishmentGroup.where(uid: "1000").first.archived_at).to eq(nil)
      expect(Support::EstablishmentGroup.where(uid: "1234").first.archived).to eq(true)
      expect(Support::EstablishmentGroup.where(uid: "1234").first.archived_at).to be_within(1.second).of(Time.zone.now)
    end
  end
end
