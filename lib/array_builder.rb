class ArrayBuilder
  # @param params [String]
  #
  # @return [Array, nil]
  def call(params)
    return if params.nil?

    if params.blank?
      []
    else
      JSON.parse(params)
    end
  end
end
