module Energy
  class VatAltPersonResponsiblesController < ApplicationController
    before_action :organisation_details
    before_action :back_url, :form_url
    before_action :form, only: %i[update]

    def show
      @form = Energy::VatAltPersonResponsibleForm.new(**@onboarding_case_organisation.to_h.compact, organisation: @onboarding_case_organisation.onboardable)
    end

    def update
      if validation.success?
        if @onboarding_case_organisation.onboardable.trust_code.blank? && validation.to_h[:vat_alt_person_address].blank?
          form_data = validation.to_h.merge(vat_alt_person_address: @organisation_detail.address)
        else
          form_data = validation.to_h
        end
    
        sanitized_data = form_data.except(:organisation)
        sanitized_data[:vat_alt_person_phone] = sanitized_data[:vat_alt_person_phone].gsub(/\D/, "")
        @onboarding_case_organisation.update!(**sanitized_data)
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
      form_params[:vat_alt_person_address] = if form_params[:vat_alt_person_address].present? 
                                                JSON.parse(form_params[:vat_alt_person_address])
                                             else
                                                {}
                                             end
      form_params
    end

    def back_url
      @back_url = energy_case_org_vat_person_responsible_path
    end

    def form_url
      @form_url = energy_case_org_vat_alt_person_responsible_path(**@routing_flags)
    end

    def redirect_path
      energy_case_org_vat_certificate_path(**@routing_flags)
    end
  end
end
