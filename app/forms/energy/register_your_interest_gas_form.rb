class Energy::RegisterYourInterestGasForm < Energy::RegisterYourInterestForm
  option :switch_gas, Types::Params::Bool | Types::Nil, optional: true
  option :gas_contract_end_date, Types::DateField, optional: true

  def valid?
    validation_messages = {}
    validation_messages[:switch_gas] = [I18n.t("energy.register_your_interests.gas.index.gas.switch_error")] if switch_gas.nil?

    if switch_gas
      date, invalid = parsed_contract_end_date(gas_contract_end_date)
      if invalid
        validation_messages[:gas_contract_end_date] = [I18n.t("energy.register_your_interests.gas.index.gas.invalid_date")]
      elsif date && !date_within_range?(date)
        validation_messages[:gas_contract_end_date] = [I18n.t("energy.register_your_interests.gas.index.gas.out_of_range")]
      end
    end

    instance_variable_set(:@messages, validation_messages)
    validation_messages.empty?
  end

  def registration_attributes
    date, = parsed_contract_end_date(gas_contract_end_date) if switch_gas
    { switch_gas:, gas_contract_end_date: date }
  end
end
