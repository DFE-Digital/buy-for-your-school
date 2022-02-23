module Support
  class EstablishmentsController < ApplicationController
    def index
      respond_to do |format|
        format.json do
          render json: EstablishmentSearch.omnisearch(params[:q]).as_json
        end
      end
    end
  end
end
