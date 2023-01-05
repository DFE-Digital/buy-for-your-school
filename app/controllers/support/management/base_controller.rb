module Support
  class Management::BaseController < ::Support::ApplicationController
    before_action :authenticate_admin!

    def index; end

  private

    def authenticate_admin!
      return render "errors/missing_role" unless current_user.admin?
    end
  end
end
