class JsonArrayType < ActiveModel::Type::Value
  def cast(value)
    return [] if value.nil?

    Array(JSON.parse(value))
  rescue JSON::ParserError
    []
  end
end

ActiveModel::Type.register(:json_array, JsonArrayType)
