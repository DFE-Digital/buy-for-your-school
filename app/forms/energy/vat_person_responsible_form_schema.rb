class Energy::VatPersonResponsibleFormSchema < Schema
  config.messages.top_namespace = :vat_person_responsible

  params do
    required(:vat_person_correct_details).value(:string)
  end

  rule(:vat_person_correct_details) do
    key.failure(:missing) if value.blank?
  end
end
