# Function to gracefully parse form field date numbers
#
class DateBuilder
  # Date fields are expected to be hashes in the format { year: #, month: #, day: # }
  #
  # @param params [Hash]
  #
  # @return [Date, nil]
  def call(params)
    case params
    when Hash
      ::Date.new(params["year"].to_i, params["month"].to_i, params["day"].to_i)
    when ::Date then params
    end
  rescue ::Date::Error
    # Day/Month/Year are either Nil or create an invalid Date
  end
end
