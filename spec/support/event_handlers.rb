module EventHandlers
  def with_event_handler(listening_to:)
    handler = double("handler")

    Array(listening_to).each do |event|
      allow(handler).to receive(event)
    end

    Wisper.subscribe(handler) do
      yield handler
    end
  end
end
