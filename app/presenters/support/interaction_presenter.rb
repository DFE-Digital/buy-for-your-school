# TODO: remove :nocov: and start testing
# :nocov:
module Support
  class InteractionPresenter < BasePresenter
    # @return [String]
    def note
      super.strip.chomp
    end
  end
end
# :nocov:
