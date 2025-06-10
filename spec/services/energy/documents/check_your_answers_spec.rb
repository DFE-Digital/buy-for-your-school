require "rails_helper"

RSpec.describe Energy::Documents::CheckYourAnswers do
  subject(:service) { described_class.new(onboarding_case) }

  let(:support_organisation) { create(:support_organisation) }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, :submitted, support_case:) }
  let(:onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation) }

  let(:pdf_data) { "--- pretend PDF summary raw data ---" }

  before do
    allow(WickedPdf).to receive(:new).and_return(double(pdf_from_string: pdf_data))
    allow(ApplicationController).to receive(:render).and_return("<html>pdf</html>")
  end

  describe "#call" do
    it "generates PDF, writes it, and attaches it to the support case" do
      attached_file = service.call
      expect(attached_file).to eq(support_case.case_attachments.first)
      expect(attached_file.attachable).to be_a(Support::Document)
      expect(attached_file.file.download).to eq(pdf_data)
    end
  end

  describe "#file_name" do
    it "returns a properly formatted filename" do
      expect(service.send(:file_name)).to include("EFS Summary")
      expect(service.send(:file_name)).to end_with(".pdf")
    end
  end

  describe "#file_path" do
    it "returns a full path in tmp directory" do
      expect(service.send(:file_path).to_s).to include("tmp")
      expect(service.send(:file_path).to_s).to end_with(".pdf")
    end
  end

  describe "#delete temp file" do
    it "deletes the temp file after attaching to case" do
      expect(File).not_to exist(service.send(:file_path).to_s)
    end
  end
end
