module Energy
  class MatSchoolPickerController < ApplicationController
    before_action :form
    skip_before_action :check_if_submitted

    # GET /energy/which-mat-schools-buying-for/:uid
    def edit
      @back_url = energy_school_selection_path
      @group = Support::EstablishmentGroup.find_by(uid: params[:uid])
      @mat_schools = @group.organisations_for_multi_school_picker.order(:name)
    end

    # POST /energy/which-mat-schools-buying-for/:uid
    def update
      mat_school_urn = params[:mat_school_picker_form][:mat_school_urn]

      redirect_to school_type_energy_authorisation_path(id: mat_school_urn, type: "single")
    end

  private

    def form
      @form = nil
    end
  end
end
