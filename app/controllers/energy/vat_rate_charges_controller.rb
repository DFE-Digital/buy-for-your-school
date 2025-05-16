module Energy
  class VatRateChargesController < ApplicationController
    before_action :organisation_details
    before_action { @back_url = energy_case_org_site_contact_details_path }
    before_action :form, only: %i[update]

    def show
      @form = Energy::VatRateChargeForm.new(**@onboarding_case_organisation.to_h.compact)
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
        %i[vat_rate vat_lower_rate_percentage].each { |key| p[key] = 0 if p[key].blank? }
      end
    end

    def redirect_path
      return energy_case_tasks_path if going_to_tasks?
      return energy_case_org_vat_person_responsible_path if @onboarding_case_organisation.reload.vat_rate == 5

      energy_case_org_vat_certificate_path
    end
  end
end
