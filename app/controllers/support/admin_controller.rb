# TODO: remove :nocov: and start testing
# :nocov:
module Support
  class AdminController < ApplicationController
    def show
      @current_user = AgentPresenter.new(current_user)
    end
  end
end
# :nocov:
