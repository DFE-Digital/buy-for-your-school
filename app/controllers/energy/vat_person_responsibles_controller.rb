module Energy
  class VatPersonResponsiblesController < ApplicationController
    before_action :organisation_details, :suggested_details
    before_action { @back_url = energy_case_org_vat_rate_charge_path }
    before_action :form, only: %i[update]

    def show
      @form = Energy::VatPersonResponsibleForm.new(**@onboarding_case_organisation.to_h.compact)
    end

    def update
      if validation.success?
        attributes = form.data
        if vat_details_correct?
          attributes.merge!({
            vat_person_first_name: current_user.first_name,
            vat_person_last_name: current_user.last_name,
            vat_person_phone: @tel,
            vat_person_address: @organisation_detail.address,
          })
        end

        @onboarding_case_organisation.update!(**attributes)
        redirect_to redirect_path
      else
        render :show
      end
    end

  private

    def vat_details_correct?
      form.data[:vat_person_correct_details] == true
    end

    def suggested_details
      @name = "#{current_user.first_name} #{current_user.last_name}"
      @address = Support::OrganisationPresenter.new(@organisation_detail).formatted_address
      @tel = @organisation_detail.telephone_number
    end

    def form
      @form = Energy::VatPersonResponsibleForm.new(
        messages: validation.errors(full: true).to_h,
        **validation.to_h,
      )
    end

    def validation
      @validation ||= Energy::VatPersonResponsibleFormSchema.new.call(**form_params)
    end

    def form_params
      params
        .fetch(:vat_person_responsible, {})
        .permit(:vat_person_correct_details)
    end

    def redirect_path
      return energy_case_tasks_path if going_to_tasks?
      # return <vat-contact-info-path> unless vat_details_correct?

      # Change to VAT certification when we have implemented the screen
      energy_case_org_vat_person_responsible_path
    end
  end
end
