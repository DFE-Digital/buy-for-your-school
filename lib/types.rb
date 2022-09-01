require "dry-types"
require "./lib/date_builder"
require "./lib/decimal_builder"
require "./lib/array_builder"

module Types
  include Dry.Types

  # Coerce dmY form date fields to a Date
  DateField = Types.Constructor(::Date) { |input| ::DateBuilder.new.call(input) }

  # Boolean radio boxes
  ConfirmationField = Types::Params::Bool | Types::String

  DecimalField = Types.Constructor(String) { |input| ::DecimalBuilder.call(input) }

  # Coerce JSON arrays to arrays
  JSONArrayField = Types.Constructor(::Array) { |input| ::ArrayBuilder.call(input) }
end
