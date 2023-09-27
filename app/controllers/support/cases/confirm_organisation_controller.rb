module Support
  module Cases
    class ConfirmOrganisationController < Cases::ApplicationController
      def show
        @back_url = edit_support_case_organisation_path(current_case)
        @new_organisation = get_organisation
      end

      def update
        organisation = get_organisation
        CaseManagement::AssignOrganisationToCase.new.call(
          support_case_id: current_case.id,
          agent_id: current_agent.id,
          organisation_id: organisation.id,
          organisation_type: organisation.class.name,
        )
        redirect_to support_case_path(current_case, anchor: "school-details"), notice: I18n.t("support.case_organisation.flash.updated")
      end

    private

      def get_organisation
        type = params[:type] == Support::EstablishmentGroup.name ? Support::EstablishmentGroup : Support::Organisation
        type.find(params[:id])
      end
    end
  end
end
