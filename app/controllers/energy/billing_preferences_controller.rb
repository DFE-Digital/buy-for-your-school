module Energy
  class BillingPreferencesController < ApplicationController
    before_action :organisation_details
    before_action { @back_url = energy_case_org_vat_certificate_path }
    before_action :form, only: %i[update]

    def show
      @form = Energy::BillingPreferencesForm.new(**@onboarding_case_organisation.to_h.compact)
    end

    def update
      if validation.success?
        @onboarding_case_organisation.update!(**form.data)
        redirect_to redirect_path
      else
        render :show
      end
    end

  private

    def form
      @form = Energy::BillingPreferencesForm.new(
        messages: validation.errors(full: true).to_h,
        **validation.to_h,
      )
    end

    def validation
      @validation ||= Energy::BillingPreferencesFormSchema.new.call(**form_params)
    end

    def form_params
      params
        .fetch(:billing_preferences, {})
        .permit(
          :billing_payment_method,
          :billing_payment_terms,
          :billing_invoicing_method,
          :billing_invoicing_email,
        )
    end

    def redirect_path
      return energy_case_tasks_path if going_to_tasks?
      return energy_case_org_billing_address_confirmation_path if paper_billing? && user_associated_with_trust?

      energy_case_check_your_answers_path
    end

    def paper_billing?
      @onboarding_case_organisation.reload.billing_invoicing_method == "paper"
    end
  end
end
