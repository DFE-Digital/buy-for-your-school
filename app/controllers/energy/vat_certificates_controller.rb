class Energy::VatCertificatesController < Energy::ApplicationController
  before_action :organisation_details
  before_action :form, only: %i[update]
  before_action :back_url, :form_url

  def show
    @form = Energy::VatCertificateForm.new(**@onboarding_case_organisation.to_h.compact)
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
    @form = Energy::VatCertificateForm.new(
      messages: validation.errors(full: true).to_h,
      **validation.to_h,
    )
  end

  def validation
    @validation ||= Energy::VatCertificateFormSchema.new.call(**form_params)
  end

  def form_params
    params.fetch(:vat_certificate_form, {}).permit(vat_certificate_declared: []).tap do |p|
      p[:vat_certificate_declared]&.reject!(&:blank?)
    end
  end

  def back_url
    @back_url = if @onboarding_case_organisation.reload.vat_rate == 20
                  energy_case_org_vat_rate_charge_path
                elsif @onboarding_case_organisation.vat_person_correct_details?
                  energy_case_org_vat_person_responsible_path
                else
                  energy_case_org_vat_alt_person_responsible_path
                end
  end

  def form_url
    @form_url = energy_case_org_vat_certificate_path(**@routing_flags)
  end

  def redirect_path
    return energy_case_check_your_answers_path if from_check?

    energy_case_org_billing_preferences_path
  end
end
