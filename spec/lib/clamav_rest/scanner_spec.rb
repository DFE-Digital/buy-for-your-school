require "spec_helper"

describe ClamavRest::Scanner do
  subject(:scanner) { described_class.new(ClamavRest::Configuration.new(service_url:)) }

  let(:service_url)       { "http://service.com/scan" }
  let(:good_api_response) { '{ Status: "OK", Description: "" }' } # Please note invalid json format is real response of api
  let(:bad_api_response)  { '{ Status: "FOUND", Description: "Eicar-Test-Signature" }' }
  let(:file)              { Tempfile.new }

  context "when given file does not contain infections" do
    before do
      stub_request(:post, service_url)
        .to_return(body: good_api_response, status: 200)
    end

    it "returns true" do
      expect(scanner.file_is_safe?(file)).to be(true)
    end
  end

  context "when given file contains infections" do
    before do
      stub_request(:post, service_url)
        .to_return(body: bad_api_response, status: 406)
    end

    it "returns false" do
      expect(scanner.file_is_safe?(file)).to be(false)
    end
  end
end
