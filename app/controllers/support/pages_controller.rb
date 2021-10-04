module Support
  class PagesController < ::Support::ApplicationController
    skip_before_action :authenticate_agent!

    def start_page; end
  end
end
