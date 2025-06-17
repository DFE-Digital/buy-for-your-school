shared_context "with attachable PDF" do |file_name|
  subject(:service) { described_class.new(onboarding_case:) }

  let(:support_organisation) { create(:support_organisation) }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, :submitted, support_case:) }

  let(:pdf_data) { "--- PDF data ---" }

  before do
    allow(WickedPdf).to receive(:new).and_return(double(pdf_from_string: pdf_data))
    allow(ApplicationController).to receive(:render).and_return("<html>pdf</html>")
  end

  describe "#call" do
    it "generates PDF and writes to tmp folder" do
      file_path = service.call
      expect(File.exist?(file_path)).to be true
    end
  end

  describe "#file_name" do
    it "returns a properly formatted filename" do
      expect(service.send(:file_name)).to include(file_name)
      expect(service.send(:file_name)).to end_with(".pdf")
    end
  end

  describe "#file_path" do
    it "returns a full path in tmp directory" do
      expect(service.send(:file_path).to_s).to include("tmp")
      expect(service.send(:file_path).to_s).to end_with(".pdf")
    end
  end
end
