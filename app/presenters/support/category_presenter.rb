module Support
  class CategoryPresenter < BasePresenter
    # @return [String]
    def title
      __getobj__.nil? ? "n/a" : super
    end
  end
end
