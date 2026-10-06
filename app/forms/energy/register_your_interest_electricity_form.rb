class Energy::RegisterYourInterestElectricityForm < Energy::RegisterYourInterestForm
  option :switch_electricity, Types::Params::Bool | Types::Nil, optional: true
  option :electricity_contract_end_date, Types::DateField, optional: true

  def valid?
    validation_messages = {}
    validation_messages[:switch_electricity] = [I18n.t("energy.register_your_interests.electricities.index.electricity.switch_error")] if switch_electricity.nil?

    if switch_electricity
      date, invalid = parsed_contract_end_date(electricity_contract_end_date)
      if invalid
        validation_messages[:electricity_contract_end_date] = [I18n.t("energy.register_your_interests.electricities.index.electricity.invalid_date")]
      elsif date && !date_within_range?(date)
        validation_messages[:electricity_contract_end_date] = [I18n.t("energy.register_your_interests.electricities.index.electricity.out_of_range")]
      end
    end

    instance_variable_set(:@messages, validation_messages)
    validation_messages.empty?
  end

  def registration_attributes
    date, = parsed_contract_end_date(electricity_contract_end_date) if switch_electricity
    { switch_electricity:, electricity_contract_end_date: date }
  end
end
