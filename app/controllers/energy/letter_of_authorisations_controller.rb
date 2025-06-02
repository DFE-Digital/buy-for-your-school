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
        # binding.pry
        @onboarding_case_organisation.update!(**form.data)

        # Support::SyncFrameworksJob.perform_later
        # Energy::GenerateLetterOfAuthorityPdf.new(@onboarding_case_organisation).call
        # GenrateVatCertificatePdfJob.perform_later(@onboarding_case_organisation)
        # GenerateCheckYourAnswersPdfJob.perform_later(@onboarding_case_organisation)
        draft_and_send_form_submission_email_to_school

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

    def draft_and_send_form_submission_email_to_school
      Energy::Emails::OnboardingFormSubmissionMailer.new(
        onboarding_case_organisation: @onboarding_case_organisation,
        to_recipients: current_user.email,
        default_email_template:,
      ).call
    end

    def default_email_template
      render_to_string(partial: "energy/letter_of_authorisations/onboarding_form_submission_email_template")
    end
  end
end
