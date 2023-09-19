module RequestForHelp
  module ContractLengthHelper
    def available_contract_lengths
      I18nOption.from("faf.contract_length.options.%%key%%", FrameworkRequest.contract_lengths.keys).sort_by(&:title)
    end
  end
end
