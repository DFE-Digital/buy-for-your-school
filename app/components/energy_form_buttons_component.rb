class EnergyFormButtonsComponent < ViewComponent::Base
  def initialize(form, include_tasks: true)
    @form = form
    @include_tasks = include_tasks
  end
end
