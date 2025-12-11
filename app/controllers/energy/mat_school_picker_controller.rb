module Energy
  class MatSchoolPickerController < ApplicationController
    before_action :back_url, :mat_schools, :form
    before_action :check_mat_feature_enabled
    skip_before_action :check_if_submitted

    # GET /energy/which-mat-schools-buying-for/:uid
    def edit; end

    # POST /energy/which-mat-schools-buying-for/:uid
    def update
      mat_school_urn = params[:mat_school_picker_form][:mat_school_urn]
      @form.mat_school_urn = mat_school_urn

      if @form.validate
        redirect_to school_type_energy_authorisation_path(id: mat_school_urn, type: "single")
      else
        render :edit
      end
    end

  private

    def form
      @form = MatSchoolPickerForm.new(current_user: UserPresenter.new(current_user))
    end

    def back_url
      @back_url ||= energy_school_selection_path
    end

    def mat_schools
      @group ||= Support::EstablishmentGroup.find_by(uid: params[:uid])
      @mat_schools ||= @group.organisations_for_multi_school_picker.order(:name)
    end

    def check_mat_feature_enabled
      unless Flipper.enabled?(:allow_mat_flow)
        redirect_to energy_service_availability_path
      end
    end
  end
end
