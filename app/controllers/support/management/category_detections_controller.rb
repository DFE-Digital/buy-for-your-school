module Support
  class Management::CategoryDetectionsController < ::Support::Management::BaseController
    before_action :build_form

    def create
      @category_results = @category_detection_form.results
      render :new
    end

  private

    def form_params
      params.fetch(:category_detection, {}).permit(:request_text)
    end

    def build_form
      @category_detection_form = CategoryDetectionForm.new(**form_params)
    end

    class CategoryDetectionForm
      include ActiveModel::Model
      attr_accessor :request_text

      def results = CategoryDetection.results_for(request_text, num_results: 10)
    end
  end
end
