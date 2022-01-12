require "dry-types"

module Types
  include Dry.Types

  CustomDate = Types.Constructor(::Date) do |input|
    if input.present?
      if input.is_a?(::Date)
        input
      else
        ::Date.new(input["year"].to_i, input["month"].to_i, input["day"].to_i)
      end
    else
      nil
    end
  rescue ArgumentError
    nil
  end
end
