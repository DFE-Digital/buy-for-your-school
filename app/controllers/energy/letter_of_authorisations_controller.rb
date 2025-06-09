module Energy
  class LetterOfAuthorisationsController < ApplicationController
    before_action :organisation_details
    before_action :form, only: %i[update]
    before_action :back_url

    def show
      @form = Energy::LetterOfAuthorisationForm.new(**@onboarding_case_organisation.to_h.compact)
    end

    def update
      if validation.success?
        @onboarding_case_organisation.update!(**form.data)

        send_form_submission_email_with_documents_to_school

        redirect_to energy_case_confirmation_path
      else
        render :show
      end
    end

  private

    def form
      @form = Energy::LetterOfAuthorisationForm.new(
        messages: validation.errors(full: true).to_h,
        **validation.to_h,
      )
    end

    def validation
      @validation ||= Energy::LetterOfAuthorisationFormSchema.new.call(**form_params)
    end

    def form_params
      params.fetch(:letter_of_authorisation_form, {}).permit(loa_agreed: []).tap do |p|
        p[:loa_agreed]&.reject!(&:blank?)
      end
    end

    def back_url
      @back_url = energy_case_check_your_answers_path
    end

    def send_form_submission_email_with_documents_to_school
      # return if onboarding_case.form_submitted_email_sent

      # TODO
      # This will create a draft email and use predefineed email template and send it to the school
      # Also it should generate 3 different PDF documents and attach them to the case and then email them
      # # The PDF documents are:
      # 1. Letter of Authority
      # 2. Check Your Answers
      # 3. VAT certificate
      # This job should run perform_later to avoid blocking the request
      # generate_documents_and_send_email_job
      Energy::GenerateDocumentsAndSendEmailJob.perform_now(
        onboarding_case_id: onboarding_case.id,
        current_user_id: current_user.id,
      )

      onboarding_case.update!(form_submitted_email_sent: true)
    end

    def onboarding_case
      @onboarding_case ||= @onboarding_case_organisation.onboarding_case
    end
  end
end
