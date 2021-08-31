module Support
  class CasePresenter < BasePresenter
    def state
      super.upcase
    end
  end
end
