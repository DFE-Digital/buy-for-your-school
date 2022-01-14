require "dry-types"
require "./lib/date_builder"

module Types
  include Dry.Types

  # Coerce dmY form date fields to a Date
  DateField = Types.Constructor(::Date) { |input| ::DateBuilder.new.call(input) }
end
