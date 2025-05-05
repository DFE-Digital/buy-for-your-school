class Energy::ElectricSupplierFormSchema < ::Support::Schema
  config.messages.top_namespace = :electric_supplier_form

  params do
    required(:electric_current_supplier).value(:string)
    required(:electric_current_contract_end_date).value(:hash)
  end

  rule(:electric_current_supplier) do
    key.failure(:missing) if value.blank?
  end

  rule(:electric_current_contract_end_date) do
    key.failure(:missing) if value.values.all?(&:blank?)
  end

  rule(:electric_current_contract_end_date) do
    if value.values.all?(&:present?)
      date = hash_to_date.call(value)
      key.failure(:invalid) if date && date.year > 9999
    end
  end
end
