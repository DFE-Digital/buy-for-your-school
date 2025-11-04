require "rails_helper"

RSpec.describe Energy::GenerateSiteAdditionAndPortalAccessXlDocuments do
  subject(:service) { described_class.new(onboarding_case:, current_user:) }

  let(:support_organisation) { create(:support_organisation) }
  let(:current_user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation, support_level: "L7") }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:onboarding_case_organisation) { create(:energy_onboarding_case_organisation, :with_energy_details, onboarding_case:, onboardable: support_organisation, **input_values) }

  let(:temp_xl_file_total) { Tempfile.new(["site_addition_total", ".xlsx"]) }
  let(:temp_xl_file_edf) { Tempfile.new(["site_addition_edf", ".xlsx"]) }

  let(:temp_portal_access_total) { Tempfile.new(["portal_access_total", ".xlsx"]) }
  let(:temp_portal_access_edf) { Tempfile.new(["portal_access_edf", ".xlsx"]) }

  let(:switching_energy_type) { :gas_electricity }

  let(:input_values) do
    {
      switching_energy_type:,
    }
  end

  before do
    onboarding_case_organisation

    allow(Energy::Documents::SiteAdditionFormTotal).to receive(:new)
      .with(onboarding_case:, current_user:)
      .and_return(double(call: temp_xl_file_total.path))

    allow(Energy::Documents::SiteAdditionFormEdf).to receive(:new)
      .with(onboarding_case:, current_user:)
      .and_return(double(call: temp_xl_file_edf.path))

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
        expect(service.documents.values).to include(temp_xl_file_total.path)
        expect(service.documents.values).to include(temp_xl_file_edf.path)
        expect(service.documents.values).to include(temp_portal_access_total.path)
        expect(service.documents.values).to include(temp_portal_access_edf.path)
      end

      it "attache both documents to the support case" do
        expect {
          service.call
        }.to change { support_case.case_attachments.count }.by(4)
      end
    end

    context "when switching gas only" do
      let(:switching_energy_type) { :gas }

      it "generates gas site addition and portal access documents" do
        service.call
        expect(service.documents.values).to include(temp_xl_file_total.path)
        expect(service.documents.values).to include(temp_portal_access_total.path)
      end

      it "attaches gas XL document to the support case" do
        expect {
          service.call
        }.to change { support_case.case_attachments.count }.by(2)
      end
    end

    context "when switching electricity only" do
      let(:switching_energy_type) { :electricity }

      it "generates electricity site addition and portal access documents" do
        service.call
        expect(service.documents.values).to include(temp_xl_file_edf.path)
        expect(service.documents.values).to include(temp_portal_access_edf.path)
      end

      it "attaches electricity XL document to the support case" do
        expect {
          service.call
        }.to change { support_case.case_attachments.count }.by(2)
      end
    end

    it "clean up temp files after running" do
      service.call

      expect(File.exist?(temp_xl_file_total.path)).to be false
      expect(File.exist?(temp_xl_file_edf.path)).to be false
      expect(File.exist?(temp_portal_access_total.path)).to be false
      expect(File.exist?(temp_portal_access_edf.path)).to be false
    end

    it "raises and logs error when document generation fails" do
      allow(Energy::Documents::SiteAdditionFormTotal).to receive(:new).and_raise(StandardError.new("generation failed"))
      expect(Rails.logger).to receive(:error).with(/Error generating documents: generation failed/)

      expect { service.call }.to raise_error(StandardError, "generation failed")
    end

    describe "update case status and procument stage" do
      let(:with_supplier) { create(:support_procurement_stage, :with_supplier) }
      let(:form_review) { create(:support_procurement_stage, :form_review) }

      let(:opened_state) { "opened" }
      let(:resolved_state) { "resolved" }

      before do
        with_supplier
        form_review
      end

      shared_examples "opened and form_review state" do
        it "updates case status to `opened` and stage to `form_review`" do
          expect(support_case.procurement_stage).to eq(form_review)
          expect(support_case.state).to eq(opened_state)
        end
      end

      shared_examples "resolved and with_supplier state" do
        it "updates case status to `resolved` and stage to `with_supplier`" do
          expect(support_case.procurement_stage).to eq(with_supplier)
          expect(support_case.state).to eq(resolved_state)
        end
      end

      context "when GAS FLAG ON and ELECTRICITY FLAG ON" do
        before do
          Flipper.enable(:auto_send_siteAdditions_gas)
          Flipper.enable(:auto_send_siteAdditions_power)
          service.call
        end

        %i[gas electricity gas_electricity].each do |energy_type|
          context "when #{energy_type} submitted" do
            let(:switching_energy_type) { energy_type }

            include_examples "resolved and with_supplier state"
          end
        end
      end

      context "when GAS FLAG OFF and ELECTRICITY FLAG OFF" do
        before do
          service.call
        end

        %i[gas electricity gas_electricity].each do |energy_type|
          context "when #{energy_type} submitted" do
            let(:switching_energy_type) { energy_type }

            include_examples "opened and form_review state"
          end
        end
      end

      context "when GAS FLAG OFF and ELECTRICITY FLAG ON" do
        before do
          Flipper.enable(:auto_send_siteAdditions_power)
          service.call
        end

        %i[gas electricity gas_electricity].each do |energy_type|
          context "when #{energy_type} submitted" do
            let(:switching_energy_type) { energy_type }

            if energy_type == :electricity
              include_examples "resolved and with_supplier state"
            else
              include_examples "opened and form_review state"
            end
          end
        end
      end

      context "when GAS FLAG ON and ELECTRICITY FLAG OFF" do
        before do
          Flipper.enable(:auto_send_siteAdditions_gas)
          service.call
        end

        %i[gas electricity gas_electricity].each do |energy_type|
          context "when #{energy_type} submitted" do
            let(:switching_energy_type) { energy_type }

            if energy_type == :gas
              include_examples "resolved and with_supplier state"
            else
              include_examples "opened and form_review state"
            end
          end
        end
      end
    end
  end
end
