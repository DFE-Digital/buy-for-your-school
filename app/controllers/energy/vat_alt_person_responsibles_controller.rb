module Energy
  class VatAltPersonResponsiblesController < ApplicationController
    before_action :organisation_details
    before_action { @back_url = energy_case_org_vat_person_responsible_path }
    before_action :form, only: %i[update]

    def show
      @form = Energy::VatAltPersonResponsibleForm.new(**@onboarding_case_organisation.to_h.compact, organisation: @onboarding_case_organisation.onboardable)
    end

    def update
      if validation.success?
        @onboarding_case_organisation.update!(**form.data.except(:organisation))
        redirect_to redirect_path
      else
        render :show
      end
    end

  private

    def form
      @form = Energy::VatAltPersonResponsibleForm.new(
        messages: validation.errors(full: true).to_h,
        organisation: @onboarding_case_organisation.onboardable,
        **validation.to_h,
      )
    end

    def validation
      @validation ||= Energy::VatAltPersonResponsibleFormSchema.new(
        organisation: @onboarding_case_organisation.onboardable,
      ).call(**form_params)
    end

    def form_params
      form_params = params.fetch(:vat_alt_person_responsible, {}).permit(:vat_alt_person_first_name, :vat_alt_person_last_name, :vat_alt_person_phone, :vat_alt_person_address)
      if form_params[:vat_alt_person_address].present?
        form_params[:vat_alt_person_address] = JSON.parse(form_params[:vat_alt_person_address])
      end

      form_params
    end

    def redirect_path
      energy_case_org_vat_certificate_path
    end
  end
end
