module Energy
  class GenerateDocumentsAndSendEmail
    include Energy::SwitchingEnergyTypeHelper
    attr_reader :onboarding_case, :onboarding_case_organisation, :current_user, :documents

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
      send_email_with_documents
    ensure
      delete_temp_files
    end

  private

    def generate_documents
      generate_letter_of_authority
      generate_check_your_answers
      generate_vat_certificates
    rescue StandardError => e
      Rails.logger.error("Error generating documents: #{e.message}")
      raise e
    end

    def send_email_with_documents
      Energy::Emails::OnboardingFormSubmissionMailer.new(onboarding_case:, to_recipients: current_user.email, documents:).call
      onboarding_case.update!(form_submitted_email_sent: true)
    end

    def generate_letter_of_authority
      documents << Energy::Documents::LetterOfAuthority.new(onboarding_case:).call
    end

    def generate_check_your_answers
      documents << Energy::Documents::CheckYourAnswers.new(onboarding_case:).call
    end

    def generate_vat_certificates
      return if onboarding_case_organisation.vat_rate != 5

      if switching_gas?
        documents << Energy::Documents::VatDeclarationFormTotal.new(onboarding_case:).call
      elsif switching_electricity?
        documents << Energy::Documents::VatDeclarationFormEdf.new(onboarding_case:).call
      else
        documents << Energy::Documents::VatDeclarationFormEdf.new(onboarding_case:).call
        documents << Energy::Documents::VatDeclarationFormTotal.new(onboarding_case:).call
      end
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
      pdf_document = File.open(document_path)
      Support::Document.create!(case: @support_case, file_type: "application/pdf", file: pdf_document)
    end

    def delete_temp_files
      documents.each do |document_path|
        File.delete(document_path) if File.exist?(document_path)
      end
    end
  end
end
