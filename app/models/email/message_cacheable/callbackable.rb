module Email::MessageCacheable::Callbackable
  extend ActiveSupport::Concern

  class_methods do
    def on_new_message_cached_handlers
      @on_new_message_cached_handlers ||= CallableComposite.new
    end
  end

  class CallableComposite
    def initialize
      @handlers = []
    end

    def add(handler)
      @handlers << handler
    end

    def call(email)
      @handlers.each do |handler|
        handler.call(email)
      end
    end
  end
end
