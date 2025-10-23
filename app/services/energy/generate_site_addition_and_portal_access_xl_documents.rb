module Energy
  class GenerateSiteAdditionAndPortalAccessXlDocuments
    include Energy::SupportDocumentsHelper
    include Energy::SwitchingEnergyTypeHelper
    attr_reader :onboarding_case, :current_user, :documents

    def initialize(onboarding_case:, current_user:)
      @onboarding_case = onboarding_case
      @support_case = @onboarding_case.support_case
      @onboarding_case_organisation = @onboarding_case.onboarding_case_organisations.first
      @current_user = current_user
      @documents = {}
    end

    def call
      ActiveRecord::Base.transaction do
        generate_site_addition_documents
        generate_portal_access_documents
        attach_documents_to_support_case
      end
      send_email_to_supplier_with_documents
    ensure
      delete_temp_files
    end

  private

    def generate_site_addition_documents
      if switching_gas?
        documents[:site_addition_gas] = Energy::Documents::SiteAdditionFormTotal.new(onboarding_case:, current_user:).call
      elsif switching_electricity?
        documents[:site_addition_electricity] = Energy::Documents::SiteAdditionFormEdf.new(onboarding_case:, current_user:).call
      else
        documents[:site_addition_gas] = Energy::Documents::SiteAdditionFormTotal.new(onboarding_case:, current_user:).call
        documents[:site_addition_electricity] = Energy::Documents::SiteAdditionFormEdf.new(onboarding_case:, current_user:).call
      end
    rescue StandardError => e
      Rails.logger.error("Error generating documents: #{e.message}")
      raise e
    end

    def generate_portal_access_documents
      if switching_gas?
        documents[:portal_access_gas] = Energy::Documents::PortalAccessFormTotal.new(onboarding_case:, current_user:).call
      elsif switching_electricity?
        documents[:portal_access_electricity] = Energy::Documents::PortalAccessFormEdf.new(onboarding_case:, current_user:).call
      else
        documents[:portal_access_gas] = Energy::Documents::PortalAccessFormTotal.new(onboarding_case:, current_user:).call
        documents[:portal_access_electricity] = Energy::Documents::PortalAccessFormEdf.new(onboarding_case:, current_user:).call
      end
    rescue StandardError => e
      Rails.logger.error("Error generating documents: #{e.message}")
      raise e
    end

    def send_email_to_supplier_with_documents
      if Flipper.enabled?(:auto_send_siteAdditions_power) && (switching_electricity? || switching_both?) && electricity_supplier_email_address.present?
        electricity_documents = documents.values_at(:site_addition_electricity, :portal_access_electricity)
        Energy::Emails::ElectricitySiteAdditionAndPortalAccessMailer.new(onboarding_case:, to_recipients: electricity_supplier_email_address, documents: electricity_documents).call
      end
      if Flipper.enabled?(:auto_send_siteAdditions_gas) && (switching_gas? || switching_both?) && gas_supplier_email_address.present?
        gas_documents = documents.values_at(:site_addition_gas, :portal_access_gas)
        Energy::Emails::GasSiteAdditionAndPortalAccessMailer.new(onboarding_case:, to_recipients: gas_supplier_email_address, documents: gas_documents).call
      end
    end

    def attach_documents_to_support_case
      documents.each_value do |document_path|
        @support_case.case_attachments.create!(
          attachable: support_document(document_path),
          custom_name: File.basename(document_path),
          description: "System uploaded document",
        )
      end
    end

    def support_document(document_path)
      xl_document = File.open(document_path)
      Support::Document.create!(
        case: @support_case,
        file_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        file: xl_document,
      )
    end

    def delete_temp_files
      documents.each_value do |document_path|
        File.delete(document_path) if File.exist?(document_path)
      end
    end

    def gas_supplier_email_address
      Energy::EmailTemplateConfiguration.find_by(energy_type: :gas, configure_option: :gas_supplier_email)&.to_email_ids
    end

    def electricity_supplier_email_address
      Energy::EmailTemplateConfiguration.find_by(energy_type: :electricity, configure_option: :electricity_supplier_email)&.to_email_ids
    end
  end
end
