# Vat Certificate Form
#
class Energy::VatCertificateForm < Energy::Form
  option :vat_certificate_declared, Types::Params::Bool | Types::Array, optional: true
end
