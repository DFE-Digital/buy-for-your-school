require "school/information"

RSpec.describe School::Information, "#call" do
  include_context "with gias data"

  context "with no file" do
    subject(:service) { described_class.new }

    before do
      travel_to Time.zone.local(2004, 11, 24, 0o1, 0o4, 44)

      stub_request(:get, "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata20041124.csv")
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
    end
  end
end
