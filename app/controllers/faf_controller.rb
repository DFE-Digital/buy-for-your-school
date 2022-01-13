class FafController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_back_url

  def index; end

  def user_query; end

private

  def validation
  end

  def set_back_url
    # placeholder
    @back_url = faf_index_path
  end

end
