require "support/frameworks/information"

RSpec.describe Support::Frameworks::Information, "#call" do
  include_context "with framework data"

  context "when the file is a File" do
    subject(:service) { described_class.new(file:) }

    let(:file) { File.open(framework_data) }

    it "outputs formatted data from the local source" do
      output = service.call.map { |eg| eg[:name] }

      expect(output).to eql [
        "Books framework",
        "Energy services",
        "Estates framework",
        "ICT services",
        "Consultancy framework",
      ]
    end
  end

  context "when the file is a String" do
    subject(:service) { described_class.new(file: framework_data) }

    it "loads the file" do
      expect(service.file.path).to eql framework_data
    end

    it "outputs formatted data from the local source" do
      output = service.call.map { |eg| eg[:supplier] }

      expect(output).to eql %w[ABC DEF GHI JKL MNO]
    end
  end
end
