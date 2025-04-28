module Energy
  class ApplicationController < ::ApplicationController
    before_action :check_flag

  private

    def check_flag
      render "errors/not_found", status: :not_found unless Flipper.enabled?(:energy)
    end
  end
end
