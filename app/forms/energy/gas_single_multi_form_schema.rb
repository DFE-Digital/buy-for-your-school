class Energy::GasSingleMultiFormSchema < Schema
  config.messages.top_namespace = :gas_single_multi

  params do
    required(:gas_single_multi).value(:string)
  end

  rule(:gas_single_multi) do
    key.failure(:missing) if value.blank?
  end
end
