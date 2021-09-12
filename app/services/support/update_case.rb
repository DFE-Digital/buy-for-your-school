# Assign a {Support::Case} to a {Support::Agent}
#
module Support
  class UpdateCase
    class UnexpectedContentfulModel < StandardError; end

    attr_reader :kase

    # @param kase [Support::Case]
    #
    def initialize(kase:)
      @kase = kase
    end

    # @see UpdateCase#call
    #
    # @return [Support::Case]
    def call
      kase.update!(state: "open")
    end
  end
end
