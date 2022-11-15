module Support
  class CategoryDetectionForm
    include ActiveModel::Model
    attr_accessor :request_text

    def results = CategoryDetection.results_for(request_text, num_results: 10)
  end
end
