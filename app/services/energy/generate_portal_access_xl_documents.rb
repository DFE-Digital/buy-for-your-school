module Energy
  class GeneratePortalAccessXlDocuments
    include Energy::SupportDocumentsHelper
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
        attach_documents_to_support_case(documents, @support_case)
      end
    ensure
      delete_temp_files(documents)
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
  end
end
