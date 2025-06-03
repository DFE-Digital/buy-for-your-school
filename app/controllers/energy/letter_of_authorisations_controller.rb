module Energy
  class LetterOfAuthorisationsController < ApplicationController
    before_action :organisation_details
    before_action :form, only: %i[update]
    before_action :back_url # check your answers page

    def show
      @form = Energy::LetterOfAuthorisationForm.new(**@onboarding_case_organisation.to_h.compact)
    end

    def update
      if validation.success?
        @onboarding_case_organisation.update!(**form.data)

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
      # TODO: change to energy_case_check_your_answers_path
      @back_url = energy_case_letter_of_authorisation_path
    end
  end
end
