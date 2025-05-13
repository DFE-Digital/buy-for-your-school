class Energy::VatRateChargeForm < Energy::Form
  option :vat_rate, Types::Params::Integer, optional: true
  option :vat_lower_rate_percentage, Types::Params::Integer, optional: true
  option :vat_lower_rate_reg_no, Types::Params::String, optional: true
end