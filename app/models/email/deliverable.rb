module Email::Deliverable
  extend ActiveSupport::Concern

  class_methods do
    def default_delivery
      @default_delivery ||= MsGraphDelivery.new
    end

    def default_delivery=(delivery)
      @default_delivery = delivery
    end
  end
end
