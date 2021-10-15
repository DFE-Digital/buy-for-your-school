module Support
  class EnquiryPresenter < BasePresenter
    # @return [CategoryPresenter]
    def category
      Support::CategoryPresenter.new(super)
    end
  end
end
