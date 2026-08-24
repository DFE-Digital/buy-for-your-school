class Energy::ElectricSupplierFormSchema < ::Support::Schema
  config.messages.top_namespace = :electric_supplier_form

  params do
    required(:electric_current_supplier).value(:string)
    required(:electric_current_contract_end_date).value(:hash)
    required(:electric_current_supplier_other).value(:string, max_size?: 60)
  end

  rule(:electric_current_supplier) do
    key.failure(:missing) if value.blank?
  end

  rule(:electric_current_contract_end_date) do
    parts = value.transform_keys(&:to_s)
    date = hash_to_date.call(parts)

    day = parts["day"]
    month = parts["month"]
    year = parts["year"]

    # Nothing entered
    if [day, month, year].all?(&:blank?)
      key.failure(:missing)
      next
    end

    # Incomplete date
    if [day, month, year].any?(&:blank?)
      key([:electric_current_contract_end_date_day]).failure(:missing_day) if day.blank?
      key([:electric_current_contract_end_date_month]).failure(:missing_month) if month.blank?
      key([:electric_current_contract_end_date_year]).failure(:missing_year) if year.blank?
      next
    end

    # Invalid date
    unless date
      key.failure(:invalid_date)
      next
    end

    # Out of range
    min_date = Date.current - 1.year
    max_date = Date.current + 5.years

    key.failure(:invalid_range) unless date.between?(min_date, max_date)
  end

  rule(:electric_current_supplier_other) do
    if values[:electric_current_supplier] == "other"
      key.failure(:missing) if value.blank?
    else
      values[:electric_current_supplier_other] = ""
    end
  end
end
