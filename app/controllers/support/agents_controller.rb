module Support
  class AgentsController < ApplicationController
    skip_before_action :authenticate_agent!, only: :create

    def create
      specify_user = User.find_by(dfe_sign_in_uid: session[:dfe_sign_in_uid])

      # NB: Agent columns do a null check which is good,
      # however in development when bypassing DSI a user has no names,
      # which will cause an issue here. Therefore:
      #
      if ::PagesController.dsi?
        specify_user.update!(
          email: session[:dfe_sign_in_uid],
          first_name: session[:dfe_sign_in_uid],
          last_name: session[:dfe_sign_in_uid],
        )
      end

      if AGENT_UUIDS.include?(specify_user.dfe_sign_in_uid)
        Agent.find_or_create_by!(dsi_uid: specify_user.dfe_sign_in_uid) do |agent|
          agent.email = specify_user.email
          agent.first_name = specify_user.first_name
          agent.last_name = specify_user.last_name
        end

        redirect_to support_cases_path
      else
        redirect_to support_root_path, notice: "Invalid Caseworker"
      end
    end
  end
end
