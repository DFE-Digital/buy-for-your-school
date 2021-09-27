module Support
  class InteractionPresenter < BasePresenter
    # @return [String]
    def note
      body.strip.chomp
    end
  end
end
