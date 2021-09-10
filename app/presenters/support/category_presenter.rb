module Support
  class CategoryPresenter < BasePresenter
    # @return [String]
    def name
      super.capitalize
    end
  end
end
