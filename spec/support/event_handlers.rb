module EventHandlers
  def with_event_handler(listening_to:)
    handler = double("handler")
    allow(handler).to receive(listening_to)

    Wisper.subscribe(handler) do
      yield handler
    end
  end
end
