#
# @see SaveAnswer
#
Result = Struct.new(:success, :object, :error_message) do
  # @return [Boolean]
  alias_method :success?, :success

  # @return [Boolean]
  def failure?
    !success
  end
end
