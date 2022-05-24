# Build a decimal string from a numeric string
class DecimalBuilder
  def self.call(param)
    case param
    when String
      # remove commas (assuming they separate thousands)
      sprintf("%.2f", param.delete(","))
    when Numeric
      sprintf("%.2f", param)
    when nil then ""
    end
  rescue ArgumentError
    # Non-numeric string
    ""
  end
end
