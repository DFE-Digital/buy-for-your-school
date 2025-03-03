class DeliverEmailJob < ApplicationJob
  queue_as :emailing # FIXME: Set this queue up?

  def perform(id, send_type)
    draft = Email::Draft.find(id)

    if send_type == :as_new_message
      draft.deliver_as_new_message
    elsif send_type == :as_reply
      draft.delivery_as_reply
    end
  end
end
