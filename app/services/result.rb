Result = Struct.new(:success, :object, :error_message) do
  def success?
    success == true
  end

  def failure?
    !success
  end
end
