module FrameworkRequests
  class EmailForm < BaseForm
    validates :email, presence: true
    validates :email, email_address: { format: true }
    validates :email, email_address: { school_email: true }

    attr_accessor :email

    def initialize(attributes = {})
      super
      @email ||= framework_request.email
    end
  end
end
