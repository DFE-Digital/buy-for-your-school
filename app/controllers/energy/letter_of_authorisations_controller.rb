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
        ActiveRecord::Base.transaction do
          @onboarding_case_organisation.update!(**form.data)
          onboarding_case.update!(submitted_at: Time.zone.now)
          onboarding_case.support_case.update!(procurement_stage: Support::ProcurementStage.find_by(key: "form_review"), state: :opened)
        end

        send_form_submission_email_with_documents_to_school
        generate_site_addition_xl_documents
        generate_portal_access_xl_documents

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
      return if onboarding_case.form_submitted_email_sent

      Energy::GenerateDocumentsAndSendEmailJob.perform_later(
        onboarding_case_id: onboarding_case.id,
        current_user_id: current_user.id,
      )
    end

    def generate_site_addition_xl_documents
      Energy::GenerateSiteAdditionXlDocumentsJob.perform_now(
        onboarding_case_id: onboarding_case.id,
        current_user_id: current_user.id,
      )
    end

    def generate_portal_access_xl_documents
      Energy::GeneratePortalAccessXlDocumentsJob.perform_now(
        onboarding_case_id: onboarding_case.id,
        current_user_id: current_user.id,
      )
    end
  end
end
