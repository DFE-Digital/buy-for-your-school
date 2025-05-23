module Energy
  class BillingAddressConfirmationsController < ApplicationController
    before_action :organisation_details, :address_orgs
    before_action { @back_url = energy_case_org_billing_preferences_path }
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

    def redirect_path
      # Change to Check your answers when we have implemented the screen
      energy_case_org_billing_address_confirmation_path
    end

    def associated_trust
      return nil if @organisation_detail.trust_code.nil?

      Support::EstablishmentGroup.find_by_uid(@organisation_detail.trust_code)
    end

    def address_orgs
      @address_orgs ||= { @organisation_detail.id => Support::OrganisationPresenter.new(@organisation_detail) }.tap do |list|
        list.merge!({ associated_trust.id => Support::OrganisationPresenter.new(associated_trust) }) if associated_trust
      end
    end
  end
end
