module FrameworkRequests
  class EmailForm < BaseForm
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    attr_accessor :email

    def initialize(attributes = {})
      super
      @email ||= framework_request.email
    end
  end
end
