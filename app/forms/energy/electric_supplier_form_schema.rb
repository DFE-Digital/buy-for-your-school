class Energy::ElectricSupplierFormSchema < ::Support::Schema
  config.messages.top_namespace = :electric_supplier_form

  params do
    required(:electric_current_supplier).value(:string)
    required(:electric_current_contract_end_date).value(:hash)
    required(:electric_current_supplier_other).value(:string)
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

      min_date = Date.current - 1.year
      max_date = Date.current + 5.years

      if date.present?
        key.failure(:invalid_range) unless date.between?(min_date, max_date)
      else
        key.failure(:invalid_date)
      end
    end
  end

  rule(:electric_current_supplier_other) do
    if values[:electric_current_supplier] == "other"
      key.failure(:missing) if value.blank?
    else
      values[:electric_current_supplier_other] = ""
    end
  end
end
