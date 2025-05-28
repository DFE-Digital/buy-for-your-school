# Validate Electricity Meter Type Form
#
class Energy::ElectricityMeterTypeFormSchema < Schema
  config.messages.top_namespace = :electricity_meter_type_form

  params do
    required(:electricity_meter_type).value(:string)
  end

  rule(:electricity_meter_type) do
    key.failure(:missing) if value.blank?
  end
end
