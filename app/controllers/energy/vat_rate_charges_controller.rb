module Energy
  class VatRateChargesController < ApplicationController
    before_action :organisation_details
    before_action :form_url, :back_url
    before_action :form, only: %i[update]

    def show
      @form = Energy::VatRateChargeForm.new(**@onboarding_case_organisation.to_h.compact)
    end

    def update
      if validation.success?
        data = form.data
        if data[:vat_rate] == 20
          data[:vat_lower_rate_percentage] = nil
          data[:vat_lower_rate_reg_no] = nil
        end
        @onboarding_case_organisation.update!(**data)
        redirect_to redirect_path
      else
        render :show
      end
    end

  private

    def form
      @form = Energy::VatRateChargeForm.new(
        messages: validation.errors(full: true).to_h,
        **validation.to_h,
      )
    end

    def validation
      @validation ||= Energy::VatRateChargeFormSchema.new.call(**form_params)
    end

    def form_params
      params.fetch(:vat_rate_charge, {})
            .permit(:vat_rate, :vat_lower_rate_percentage, :vat_lower_rate_reg_no).tap do |p|
        # Default to 0 for integers
        %i[vat_rate vat_lower_rate_percentage].each { |key| p[key] = "0" if p[key].blank? }
      end
    end

    def form_url
      @form_url = energy_case_org_vat_rate_charge_path(**@routing_flags)
    end

    def back_url
      @back_url = energy_case_org_site_contact_details_path
    end

    def redirect_path
      return energy_case_tasks_path if going_to_tasks? || (from_tasks? && vat_rate_20?)
      return energy_case_check_your_answers_path if from_check? && vat_rate_20?
      return energy_case_org_vat_person_responsible_path(**@routing_flags) if vat_rate_5?
      return energy_case_org_billing_preferences_path if vat_rate_20?

      energy_case_org_vat_certificate_path
    end

    def vat_rate_5?
      @onboarding_case_organisation.reload.vat_rate == 5
    end

    def vat_rate_20?
      @onboarding_case_organisation.reload.vat_rate == 20
    end
  end
end
