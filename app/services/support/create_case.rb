module Support
  #
  # Service to open Case from JSON
  #
  class CreateCase
    # @param support_request [JSON] incoming request for support

    def initialize(support_request)
      @support_request = support_request
    end

    # @return [Support::Case]
    def call; end
  end
end
