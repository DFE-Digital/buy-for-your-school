# TODO: remove :nocov: and start testing
# :nocov:
module Support
  class Agent < ApplicationRecord

    def guest?
      false
    end
  end
end
# :nocov:
