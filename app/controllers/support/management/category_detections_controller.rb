module Support
  class Management::CategoryDetectionsController < ::Support::Management::BaseController
    before_action :build_form
    before_action :set_stats

    def create
      @category_results = @category_detection_form.results
      render :new
    end

  private

    def form_params = params.fetch(:category_detection, {}).permit(:request_text)

    def build_form = @category_detection_form = CategoryDetectionForm.new(**form_params)

    def set_stats = @stats = CategoryDetectionStats.stats
  end
end
