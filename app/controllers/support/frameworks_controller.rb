module Support
  class FrameworksController < ApplicationController
    def index
      respond_to do |format|
        format.json do
          methods = %i[display_status
                       reference_and_name
                       category_names
                       provider_name
                       display_provider_start_date
                       display_provider_end_date]

          render json: ::Frameworks::Framework
            .not_evaluating
            .where(status: %w[dfe_approved cab_approved])
            .omnisearch(params[:q])
            .order("reference DESC")
            .as_json(methods:)
        end
      end
    end
  end
end
