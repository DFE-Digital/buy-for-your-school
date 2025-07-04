module Energy
  class GeneratePortalAccessXlDocuments
    include Energy::SwitchingEnergyTypeHelper
    attr_reader :onboarding_case, :current_user, :documents

    def initialize(onboarding_case:, current_user:)
      @onboarding_case = onboarding_case
      @support_case = @onboarding_case.support_case
      @onboarding_case_organisation = @onboarding_case.onboarding_case_organisations.first
      @current_user = current_user
      @documents = []
    end

    def call
      ActiveRecord::Base.transaction do
        generate_documents
        attach_documents_to_support_case
      end
    ensure
      delete_temp_files
    end

  private

    def generate_documents
      if switching_gas?
        documents << Energy::Documents::PortalAccessFormTotal.new(onboarding_case:, current_user:).call
      elsif switching_electricity?
        documents << Energy::Documents::PortalAccessFormEdf.new(onboarding_case:, current_user:).call
      else
        documents << Energy::Documents::PortalAccessFormTotal.new(onboarding_case:, current_user:).call
        documents << Energy::Documents::PortalAccessFormEdf.new(onboarding_case:, current_user:).call
      end
    rescue StandardError => e
      Rails.logger.error("Error generating documents: #{e.message}")
      raise e
    end

    def attach_documents_to_support_case
      documents.each do |document_path|
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
      documents.each do |document_path|
        File.delete(document_path) if File.exist?(document_path)
      end
    end
  end
end
