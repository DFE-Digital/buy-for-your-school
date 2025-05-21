module Energy
  class ServiceAvailabilityController < ApplicationController
    before_action :establishment_group
    before_action { @back_url = energy_school_selection_path }
    def show; end

  private

    def establishment_group
      establishment_group = Support::EstablishmentGroup.find_by(uid: params[:id])
      @org_name = establishment_group ? establishment_group.name : ""
    end
  end
end
