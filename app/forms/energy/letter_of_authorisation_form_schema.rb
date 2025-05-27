class Energy::LetterOfAuthorisationFormSchema < Schema
  config.messages.top_namespace = :letter_of_authorisation_form

  params do
    required(:loa_agreed).value(:array)
  end

  rule(:loa_agreed) do
    key.failure(:select_all) if value.is_a?(Array) && value.length <= 2
  end
end
