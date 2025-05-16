class Energy::VatCertificatesController < Energy::ApplicationController
  before_action :organisation_details
  before_action :form, only: %i[update]
  before_action :back_url

  def show
    @form = Energy::VatCertificateForm.new(**@onboarding_case_organisation.to_h.compact)
  end

  def update
    if validation.success?
      @onboarding_case_organisation.update!(**form.data)

      # TODO: Update this to the correct path
      redirect_to energy_case_org_vat_certificate_path
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
    @back_url = if @onboarding_case_organisation.vat_person_correct_details?
                  energy_case_org_vat_person_responsible_path
                else
                  energy_case_org_vat_alt_person_responsible_path
                end
  end
end
