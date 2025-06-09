# Vat Certificate Form
#
class Energy::VatCertificateFormSchema < Schema
  config.messages.top_namespace = :vat_certificate_form

  params do
    required(:vat_certificate_declared).value(:array)
  end

  rule(:vat_certificate_declared) do
    key.failure(:select_all) if value.is_a?(Array) && value.length <= 2
  end
end
