module Support
  class Cases::DocumentsController < Cases::ApplicationController
    def show
      @document = @current_case.documents.for_rendering.find(params[:id])
    end
  end
end
