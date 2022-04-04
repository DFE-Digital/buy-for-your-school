module Support
  class FrameworksController < ApplicationController
    def index
      respond_to do |format|
        format.json do
          render json: Framework.omnisearch(params[:q]).map { |f| FrameworkPresenter.new(f) }.as_json
        end
      end
    end
  end
end
