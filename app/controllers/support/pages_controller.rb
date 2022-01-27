module Support
  class PagesController < ::Support::ApplicationController
    skip_before_action :authenticate_agent!

    def start_page
      redirect_to support_cases_path if current_agent
    end
  end
end
