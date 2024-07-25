module Support
  class EstablishmentsController < ::ApplicationController
    def index
      respond_to do |format|
        format.json do
          render json: EstablishmentSearch.omnisearch(params[:q]).as_json(methods: %i[autocomplete_template])
        end
      end
    end

    def list_for_non_participating_establishment
      respond_to do |format|
        format.json do
          render json: EstablishmentSearch.omnisearch(params[:q]).where("establishment_type not in (?)", ["Federation", "Trust", "Single-academy Trust", "Multi-academy Trust", "Umbrella trust", "Local authority"]).as_json(methods: %i[autocomplete_template])
        end
      end
    end

  protected

    def authorize_agent_scope = :access_establishment_search?
  end
end
