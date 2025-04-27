module Energy
  class SwitchEnergy < ApplicationRecord
    # Energy type
    #
    #   electricity       - Electricity only
    #   gas               - Gas only
    #   electricity_gas   - Gas and electricity
    enum :energy_types, { electricity: 0, gas: 1, gas_electricity: 2 }
  end
end
