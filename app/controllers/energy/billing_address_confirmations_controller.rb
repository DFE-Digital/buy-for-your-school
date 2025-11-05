module Energy
  class BillingAddressConfirmationsController < ApplicationController
    before_action :organisation_details, :address_orgs
    before_action :back_url, :form_url
    before_action :form, only: %i[update]

    def show
      @form = Energy::BillingAddressConfirmationForm.new(**@onboarding_case_organisation.to_h.compact)
    end

    def update
      if validation.success?
        attributes = form.data.merge(
          billing_invoice_address: @address_orgs[form.billing_invoice_address_source_id].address,
        )
        @onboarding_case_organisation.update!(**attributes)
        redirect_to redirect_path
      else
        render :show
      end
    end

  private

    def form
      @form = Energy::BillingAddressConfirmationForm.new(
        messages: validation.errors(full: true).to_h,
        **validation.to_h,
      )
    end

    def validation
      @validation ||= Energy::BillingAddressConfirmationFormSchema.new.call(**form_params)
    end

    def form_params
      params.fetch(:billing_address_confirmation, {}).permit(:billing_invoice_address_source_id)
    end

    def back_url
      @back_url = energy_case_org_billing_preferences_path
    end

    def form_url
      @form_url = energy_case_org_billing_address_confirmation_path(**@routing_flags)
    end

    def redirect_path
      return energy_case_tasks_path if from_tasks?

      energy_case_check_your_answers_path
    end

    def address_orgs
      associated_trust = @onboarding_case_organisation.trust_organisation

      @address_orgs ||= {
        @organisation_detail.id => Support::OrganisationPresenter.new(@organisation_detail),
      }.tap do |list|
        list.merge!({ associated_trust.id => Support::OrganisationPresenter.new(associated_trust) }) if associated_trust
      end
    end
  end
end
