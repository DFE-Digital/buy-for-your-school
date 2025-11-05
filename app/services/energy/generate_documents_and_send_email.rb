module Energy
  class GenerateDocumentsAndSendEmail
    include Energy::SwitchingEnergyTypeHelper
    attr_reader :onboarding_case, :onboarding_case_organisation, :current_user,
                :documents, :dd_vat_edf_documents, :dd_vat_total_documents,
                :edf_vat_documents, :edf_dd_documents,
                :total_vat_documents, :total_dd_documents

    def initialize(onboarding_case:, current_user:)
      @onboarding_case = onboarding_case
      @support_case = @onboarding_case.support_case
      @onboarding_case_organisation = @onboarding_case.onboarding_case_organisations.first
      @current_user = current_user
      @documents = []
      @dd_vat_edf_documents = []
      @dd_vat_total_documents = []
      @edf_vat_documents = []
      @edf_dd_documents = []
      @total_vat_documents = []
      @total_dd_documents = []
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
      generate_edf_direct_debit_form
      generate_total_direct_debit_form
    rescue StandardError => e
      Rails.logger.error("Error generating documents: #{e.message}")
      raise e
    end

    def send_email_with_documents
      Energy::Emails::OnboardingFormSubmissionMailer.new(onboarding_case:, to_recipients: current_user.email, documents:).call

      if Flipper.enabled?(:auto_email_vat_dd)
        Energy::Emails::OnboardingFormVatEdfMailer.new(onboarding_case:, to_recipients: current_user.email, documents: edf_vat_documents).call if eligible_non_dd_vat_edf?
        Energy::Emails::OnboardingFormDdEdfMailer.new(onboarding_case:, to_recipients: current_user.email, documents: edf_dd_documents).call if eligible_dd_edf?
        Energy::Emails::NonDirectDebitVatTotalMailer.new(onboarding_case:, to_recipients: current_user.email, documents: total_vat_documents).call if eligible_non_dd_vat_total?
        Energy::Emails::OnboardingFormDdTotalMailer.new(onboarding_case:, to_recipients: current_user.email, documents: total_dd_documents).call if eligible_dd_total?
        Energy::Emails::DirectDebitVatEdfMailer.new(onboarding_case:, to_recipients: current_user.email, documents: dd_vat_edf_documents).call if eligible_dd_vat_edf?
        Energy::Emails::DirectDebitVatTotalMailer.new(onboarding_case:, to_recipients: current_user.email, documents: dd_vat_total_documents).call if eligible_dd_vat_total?
      end

      onboarding_case.update!(form_submitted_email_sent: true)
    end

    def eligible_non_dd_vat_edf?
      (switching_electricity? || switching_both?) && @onboarding_case_organisation.billing_payment_method_bacs? && @onboarding_case_organisation.vat_rate == 5
    end

    def eligible_dd_total?
      (switching_gas? || switching_both?) && @onboarding_case_organisation.billing_payment_method_direct_debit? && @onboarding_case_organisation.vat_rate == 20
    end

    def eligible_non_dd_vat_total?
      (switching_gas? || switching_both?) && @onboarding_case_organisation.billing_payment_method_bacs? && @onboarding_case_organisation.vat_rate == 5
    end

    def eligible_dd_edf?
      (switching_electricity? || switching_both?) && @onboarding_case_organisation.billing_payment_method_direct_debit? && @onboarding_case_organisation.vat_rate == 20
    end

    def eligible_dd_vat_edf?
      (switching_electricity? || switching_both?) && @onboarding_case_organisation.billing_payment_method_direct_debit? && @onboarding_case_organisation.vat_rate == 5
    end

    def eligible_dd_vat_total?
      (switching_gas? || switching_both?) && @onboarding_case_organisation.billing_payment_method_direct_debit? && @onboarding_case_organisation.vat_rate == 5
    end

    def generate_letter_of_authority
      documents << Energy::Documents::LetterOfAuthority.new(onboarding_case:).call
    end

    def generate_check_your_answers
      documents << Energy::Documents::CheckYourAnswers.new(onboarding_case:).call
    end

    def generate_edf_direct_debit_form
      if (switching_electricity? || switching_both?) && @onboarding_case_organisation.billing_payment_method_direct_debit?
        Energy::Documents::DirectDebitFormEdf.new(onboarding_case:, current_user:).call.tap do |doc|
          edf_dd_documents << doc
          dd_vat_edf_documents << doc
        end
      end
    end

    def generate_vat_certificates
      return if onboarding_case_organisation.vat_rate != 5

      if switching_gas?
        Energy::Documents::VatDeclarationFormTotal.new(onboarding_case:).call.tap do |doc|
          documents << doc unless Flipper.enabled?(:auto_email_vat_dd)
          dd_vat_total_documents << doc
          total_vat_documents << doc
        end
      elsif switching_electricity?
        Energy::Documents::VatDeclarationFormEdf.new(onboarding_case:).call.tap do |doc|
          documents << doc unless Flipper.enabled?(:auto_email_vat_dd)
          dd_vat_edf_documents << doc
          edf_vat_documents << doc
        end
      else
        Energy::Documents::VatDeclarationFormEdf.new(onboarding_case:).call.tap do |doc|
          documents << doc unless Flipper.enabled?(:auto_email_vat_dd)
          dd_vat_edf_documents << doc
          edf_vat_documents << doc
        end
        Energy::Documents::VatDeclarationFormTotal.new(onboarding_case:).call.tap do |doc|
          documents << doc unless Flipper.enabled?(:auto_email_vat_dd)
          dd_vat_total_documents << doc
          total_vat_documents << doc
        end
      end
    end

    def generate_total_direct_debit_form
      if (switching_gas? || switching_both?) && @onboarding_case_organisation.billing_payment_method_direct_debit?
        Energy::Documents::DirectDebitFormTotal.new(onboarding_case:, current_user:).call.tap do |doc|
          total_dd_documents << doc
          dd_vat_total_documents << doc
        end
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

      dd_vat_edf_documents.each do |document_path|
        @support_case.case_attachments.create!(
          attachable: support_document(document_path),
          custom_name: File.basename(document_path),
          description: "System uploaded document",
        )
      end

      dd_vat_total_documents.each do |document_path|
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
      dd_vat_edf_documents.each do |document_path|
        File.delete(document_path) if File.exist?(document_path)
      end
      dd_vat_total_documents.each do |document_path|
        File.delete(document_path) if File.exist?(document_path)
      end
    end
  end
end
