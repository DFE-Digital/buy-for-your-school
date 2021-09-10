# TODO: remove :nocov: and start testing
# :nocov:
module Support
  class Agent < ApplicationRecord
    has_one :profile

    def self.all
      [
        OpenStruct.new(
          id: 1,
          name: "John Kendle",
        ),
      ]
    end
  end
end
# :nocov:
