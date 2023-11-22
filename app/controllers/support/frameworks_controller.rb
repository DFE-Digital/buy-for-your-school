module Support
  class FrameworksController < ApplicationController
    def index
      respond_to do |format|
        format.json do
          methods = %i[display_status
                       reference_and_name
                       category_names
                       provider_name
                       display_dfe_start_date
                       display_dfe_end_date]

          render json: ::Frameworks::Framework
            .not_evaluating
            .omnisearch(params[:q])
            .as_json(methods:)
        end
      end
    end
  end
end
