# Validate Switch Energy Form
#
class Energy::SwitchEnergyFormSchema < Schema
  config.messages.top_namespace = :switch_energy_form

  params do
    required(:switching_energy_type).value(:string)
  end

  rule(:switching_energy_type) do
    key.failure(:missing) if value.blank?
  end
end
