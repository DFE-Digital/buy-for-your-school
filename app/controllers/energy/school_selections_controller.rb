module Energy
  class SchoolSelectionsController < ApplicationController
    skip_before_action :check_if_submitted
    before_action :form, only: %i[update]
    before_action :select_schools

    def show
      @form = Energy::SchoolSelectionsForm.new(**select_schools.to_h)
    end

    def update
      if validation.success?
        urn_uid, id = form_params[:select_school].split("_", 2)
        case urn_uid
        when "urn"
          redirect_to school_type_energy_authorisation_path(id:, type: "single")
        when "uid"
          # TODO: Update this when MAT service is available
          # redirect_to school_type_energy_authorisation_path(id: id, type: "mat")
          redirect_to energy_service_availability_path(id:)
        else
          redirect_to energy_school_selection_path
        end
      else
        render :show
      end
    end

  private

    def select_schools
      @select_schools = current_user.orgs.map do |org|
        key = org["urn"] ? "urn_#{org['urn']}" : "uid_#{org['uid']}"
        [key, org["name"]]
      end
    end

    def form
      @form = Energy::SchoolSelectionsForm.new(
        messages: validation.errors(full: true).to_h,
        **validation.to_h,
      )
    end

    def validation
      @validation ||= Energy::SchoolSelectionsFormSchema.new.call(**form_params)
    end

    def form_params
      params.fetch(:school_selection_form, {}).permit(:select_school)
    end
  end
end
