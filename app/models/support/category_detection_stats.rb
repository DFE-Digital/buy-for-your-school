module Support
  class CategoryDetectionStats
    attr_reader :categories_detected, :categories_unchanged, :overall_accuracy

    def initialize
      @categories_detected  = Support::Case.where("detected_category_id IS NOT NULL").count
      @categories_unchanged = Support::Case.where("detected_category_id IS NOT NULL AND category_id = detected_category_id").count
      @overall_accuracy     = (categories_unchanged.to_f / categories_detected) * 100
    end
  end
end
