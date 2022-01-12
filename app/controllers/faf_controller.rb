class FafController < ApplicationController
  skip_before_action :authenticate_user!

  def new; end
end
