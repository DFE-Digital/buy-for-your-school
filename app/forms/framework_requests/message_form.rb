module FrameworkRequests
  class MessageForm < BaseForm
    validates :message_body, presence: true

    attr_accessor :message_body

    def initialize(attributes = {})
      super
      @message_body ||= framework_request.message_body
    end
  end
end
