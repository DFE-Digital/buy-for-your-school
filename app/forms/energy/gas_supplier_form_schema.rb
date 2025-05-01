class Energy::GasSupplierFormSchema < ::Support::Schema
  config.messages.top_namespace = :gas_supplier_form

  params do
    required(:gas_current_supplier).value(:string)
    required(:gas_current_contract_end_date).value(:hash)
  end

  rule(:gas_current_supplier) do
    key.failure(:missing) if value.blank?
  end

  rule(:gas_current_contract_end_date) do
    key.failure(:missing) if value.values.all?(&:blank?)
  end

  rule(:gas_current_contract_end_date) do
    if value.values.all?(&:present?)
      date = hash_to_date.call(value)
      key.failure(:invalid) if date && date.year > 9999
    end
  end
end
