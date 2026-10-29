# frozen_string_literal: true

require "bigdecimal"

module Energy
  module GasPriceFormatting
    def self.format(value)
      rounded = BigDecimal(value.to_s).round(3, BigDecimal::ROUND_HALF_UP).to_s("F")
      whole, fraction = rounded.split(".")
      "#{whole}.#{fraction.to_s.ljust(3, '0')}"
    end
  end
end
