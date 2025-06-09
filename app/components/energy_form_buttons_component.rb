class EnergyFormButtonsComponent < ViewComponent::Base
  def initialize(form, routing_flags: {})
    @form = form
    @routing_flags = routing_flags
  end
end
