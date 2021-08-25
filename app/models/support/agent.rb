# TODO: remove :nocov: and start testing
# :nocov:
module Support
  class Agent < ApplicationRecord
    has_one :profile
  end
end
# :nocov:
