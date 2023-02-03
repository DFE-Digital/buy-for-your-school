module Support
  class CategoryDetectionForm
    include ActiveModel::Model
    attr_accessor :request_text, :simulate_energy_request

    def results = CategoryDetection.results_for(request_text, is_energy_request: simulate_energy_request == "true", num_results: 10)
  end
end
