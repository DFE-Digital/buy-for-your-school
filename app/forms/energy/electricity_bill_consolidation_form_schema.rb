class Energy::ElectricityBillConsolidationFormSchema < Schema
  config.messages.top_namespace = :electricity_bill_consolidation_form

  params do
    required(:is_electricity_bill_consolidated).value(:string)
  end

  rule(:is_electricity_bill_consolidated) do
    key.failure(:missing) if value.blank?
  end
end
