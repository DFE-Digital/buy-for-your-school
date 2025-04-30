module Energy
  class GasSupplierController < ApplicationController
    def show; end

    def update
      if valid_gas_supplier_params?
        energy_onboarding_case_organisation.update!(
          gas_current_supplier: gas_supplier_form_params[:gas_current_supplier].to_i,
          gas_current_contract_end_date: contract_end_date,
        )
        redirect_to energy_mat_gas_contract_path
      else
        flash[:error] = { message: "Please fill in all fields", class: "govuk-error" }
        render :show
      end
    end

    private

    def energy_onboarding_case_organisation
      @energy_onboarding_case_organisation ||= Energy::OnboardingCaseOrganisation.first
    end

    def gas_supplier_form_params
      params.require(:gas_supplier).permit(
        :gas_current_supplier,
        :contract_end_day,
        :contract_end_month,
        :contract_end_year,
      )
    end

    def contract_end_date
      Date.new(
        gas_supplier_form_params[:contract_end_year].to_i,
        gas_supplier_form_params[:contract_end_month].to_i,
        gas_supplier_form_params[:contract_end_day].to_i,
      )
    rescue ArgumentError
      nil
    end

    def valid_gas_supplier_params?
      gas_supplier_form_params[:gas_current_supplier].present? && contract_end_date.present?
    end
  end
end
