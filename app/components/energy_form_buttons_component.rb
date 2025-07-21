class EnergyFormButtonsComponent < ViewComponent::Base
  def initialize(form, routing_flags: {}, submit_button_additional_classes: "")
    @form = form
    @routing_flags = routing_flags
    @submit_button_additional_classes = submit_button_additional_classes
  end
end
