class Energy::GasSupplierFormSchema < ::Support::Schema
  config.messages.top_namespace = :gas_supplier_form

  params do
    required(:gas_current_supplier).value(:string)
    required(:gas_current_contract_end_date).value(:hash)
    required(:gas_current_supplier_other).value(:string, max_size?: 60)
  end

  rule(:gas_current_supplier) do
    key.failure(:missing) if value.blank?
  end

  rule(:gas_current_contract_end_date) do
    validate_date_parts(
      self,
      :gas_current_contract_end_date,
      value,
      min: Date.current - 1.year,
      max: Date.current + 5.years,
    )
  end

  rule(:gas_current_supplier_other) do
    if values[:gas_current_supplier] == "other"
      key.failure(:missing) if value.blank?
    else
      values[:gas_current_supplier_other] = ""
    end
  end
end
