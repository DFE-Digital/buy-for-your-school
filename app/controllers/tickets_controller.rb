class TicketsController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        render json: TicketSearch.omnisearch(params[:q]).as_json
      end
    end
  end
end
