Result = Struct.new(:success, :object, :error_message) {
  def success?
    success == true
  end

  def failure?
    !success
  end
}
