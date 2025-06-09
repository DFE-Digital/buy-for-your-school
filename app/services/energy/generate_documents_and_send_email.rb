# generate_documents_and_send_email
module Energy
  class GenerateDocumentsAndSendEmail
    attr_reader :onboarding_case, :onboarding_case_organisation, :current_user, :documents

    def initialize(onboarding_case:, current_user:)
      @onboarding_case = onboarding_case
      @onboarding_case_organisation = @onboarding_case.onboarding_case_organisations.first
      @current_user = current_user
      @documents = []
    end

    def call
      generate_documents
      send_email_with_documents
    end

  private

    def generate_documents
      letter_of_authority
      # documents << Energy::Documents::CheckYourAnswers.new(onboarding_case:).generate
      # documents << Energy::Documents::VatDeclarationFormEdf.new(onboarding_case:).generate if onboarding_case_organisation.vat_rate == 5
    rescue StandardError => e
      Rails.logger.error("Error generating documents: #{e.message}")
      raise e
    end

    def send_email_with_documents
      Energy::Emails::OnboardingFormSubmissionMailer.new(onboarding_case:, to_recipients: current_user.email, documents:).call
      onboarding_case.update!(form_submitted_email_sent: true)
    end

    def letter_of_authority
      loa_service = Energy::Documents::LetterOfAuthority.new(onboarding_case)
      loa_service.call
      @documents << loa_service.pdf_document
    end
  end
end
