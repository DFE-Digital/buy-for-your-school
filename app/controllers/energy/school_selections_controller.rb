module Energy
  class SchoolSelectionsController < ApplicationController
    skip_before_action :check_if_submitted
    before_action :form, only: %i[update]
    before_action :valid_support_organisation
    before_action :valid_establishment_group
    before_action :select_schools

    def show
      @form = Energy::SchoolSelectionsForm.new(**select_schools.to_h)
    end

    def update
      if validation.success?
        urn_uid, id = form_params[:select_school].split("_", 2)
        case urn_uid
        when "urn"
          # User has selected a single school
          redirect_to school_type_energy_authorisation_path(id:, type: "single")
        when "uid"
          # User has selected a Trust so show MAT school picker
          if Flipper.enabled?(:allow_mat_flow)
            redirect_to energy_mat_school_picker_path(uid: id)
          else
            redirect_to energy_service_availability_path(id:)
          end
        else
          redirect_to energy_school_selection_path
        end
      else
        render :show
      end
    end

  private

    def select_schools
      valid_urns = @valid_support_organisation.pluck(:urn)
      valid_uids = @valid_establishment_group.pluck(:uid)

      @select_schools = current_user.orgs
        .select { |org| valid_urns.include?(org["urn"]) || valid_uids.include?(org["uid"]) }
        .map { |org| ["#{org['urn'] ? 'urn' : 'uid'}_#{org['urn'] || org['uid']}", org["name"]] }
    end

    def valid_support_organisation
      @valid_support_organisation = Support::Organisation.all
    end

    def valid_establishment_group
      @valid_establishment_group = Support::EstablishmentGroup.all
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
