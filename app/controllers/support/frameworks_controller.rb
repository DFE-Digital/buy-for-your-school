module Support
  class FrameworksController < ApplicationController
    def index
      respond_to do |format|
        format.json do
          if Flipper.enabled?(:framework_select_from_register)
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
          else
            render json: Framework.omnisearch(params[:q]).map { |f| FrameworkPresenter.new(f) }.as_json
          end
        end
      end
    end
  end
end
