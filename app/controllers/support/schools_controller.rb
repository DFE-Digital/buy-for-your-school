module Support
  class SchoolsController < ApplicationController
    def show
      @org = Organisation.find_by(urn: params[:id])
    end

    def index
      respond_to do |format|
        format.json do
          render json: Organisation
            .where("urn LIKE ?", "#{params.fetch(:q)}%")
            .limit(25)
            .as_json(only: %i[id urn name], methods: [:postcode])
        end
      end
    end
  end
end
