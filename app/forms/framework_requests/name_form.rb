module FrameworkRequests
  class NameForm < BaseForm
    validates :first_name, presence: true
    validates :last_name, presence: true

    attr_accessor :first_name, :last_name

    def initialize(attributes = {})
      super
      @first_name ||= framework_request.first_name
      @last_name ||= framework_request.last_name
    end
  end
end
