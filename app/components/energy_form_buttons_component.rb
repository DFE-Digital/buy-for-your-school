class EnergyFormButtonsComponent < ViewComponent::Base
  def initialize(form, routing_flags: {}, additional_classes: "")
    @form = form
    @routing_flags = routing_flags
    @additional_classes = additional_classes
  end
end
