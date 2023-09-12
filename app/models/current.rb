class Current < ActiveSupport::CurrentAttributes
  attribute :user, :agent, :actor, :request_id
end
