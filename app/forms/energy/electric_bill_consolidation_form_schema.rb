class Energy::ElectricBillConsolidationFormSchema < Schema
  config.messages.top_namespace = :electric_bill_consolidation_form

  params do
    required(:is_electric_bill_consolidated).value(:string)
  end

  rule(:is_electric_bill_consolidated) do
    key.failure(:missing) if value.blank?
  end
end
