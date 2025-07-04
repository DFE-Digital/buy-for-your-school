require "rails_helper"

RSpec.describe Energy::GeneratePortalAccessXlDocuments do
  subject(:service) { described_class.new(onboarding_case:, current_user:) }

  let(:support_organisation) { create(:support_organisation) }
  let(:current_user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:onboarding_case_organisation) { create(:energy_onboarding_case_organisation, :with_energy_details, onboarding_case:, onboardable: support_organisation, **input_values) }

  let(:temp_portal_access_total) { Tempfile.new(["portal_access_total", ".xlsx"]) }
  let(:temp_portal_access_edf) { Tempfile.new(["portal_access_edf", ".xlsx"]) }
  let(:switching_energy_type) { :gas_electricity }

  let(:input_values) do
    {
      switching_energy_type:,
    }
  end

  before do
    current_user
    onboarding_case_organisation

    allow(Energy::Documents::PortalAccessFormTotal).to receive(:new)
      .with(onboarding_case:, current_user:)
      .and_return(double(call: temp_portal_access_total.path))

    allow(Energy::Documents::PortalAccessFormEdf).to receive(:new)
      .with(onboarding_case:, current_user:)
      .and_return(double(call: temp_portal_access_edf.path))
  end

  describe "#call" do
    context "when switching gas and electricity" do
      it "generates both EDF and total energy documents" do
        service.call
        expect(service.documents).to include(temp_portal_access_total.path)
        expect(service.documents).to include(temp_portal_access_edf.path)
      end

      it "attache both documents to the support case" do
        expect {
          service.call
        }.to change { support_case.case_attachments.count }.by(2)
      end
    end

    context "when switching gas only" do
      let(:switching_energy_type) { :gas }

      it "generates total energy portal access XL document" do
        service.call
        expect(service.documents).to include(temp_portal_access_total.path)
      end

      it "attaches Total Energy Portal Access XL document to the support case" do
        expect {
          service.call
        }.to change { support_case.case_attachments.count }.by(1)
      end
    end

    context "when switching electricity only" do
      let(:switching_energy_type) { :electricity }

      it "generates EDF Energy Portal Access XL document" do
        service.call
        expect(service.documents).to include(temp_portal_access_edf.path)
      end

      it "attaches EDF Energy Portal Access XL document to the support case" do
        expect {
          service.call
        }.to change { support_case.case_attachments.count }.by(1)
      end
    end

    it "clean up temp XL files after running" do
      service.call

      expect(File.exist?(temp_portal_access_total.path)).to be false
      expect(File.exist?(temp_portal_access_edf.path)).to be false
    end

    it "raises and logs error when document generation fails" do
      allow(Energy::Documents::PortalAccessFormTotal).to receive(:new).and_raise(StandardError.new("generation failed"))
      expect(Rails.logger).to receive(:error).with(/Error generating documents: generation failed/)

      expect { service.call }.to raise_error(StandardError, "generation failed")
    end
  end
end
