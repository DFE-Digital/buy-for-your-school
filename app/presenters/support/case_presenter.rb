# TODO: remove :nocov: and start testing
# :nocov:
module Support
  class CasePresenter < BasePresenter
    def state
      super.upcase
    end
  end
end
# :nocov: