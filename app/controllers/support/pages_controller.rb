module Support
  class PagesController < ApplicationController
    skip_before_action :authenticate_agent!

    def support_start_page; end
  end
end