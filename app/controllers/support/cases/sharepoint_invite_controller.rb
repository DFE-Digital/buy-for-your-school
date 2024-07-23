module Support
  class Cases::SharepointInviteController < Cases::ApplicationController
    def create
      res = @current_case.invite_contact_to_sharepoint
      status = res.body["status"]
      if status == "PendingAcceptance"
        notice = "Invitation pending acceptance"
        @current_case.update!(contact_invited_to_sharepoint: true)
      else
        notice = "Something went wrong"
      end
      redirect_back fallback_location: support_case_path(@current_case), notice:
    end
  end
end
