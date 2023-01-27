class RequestForm < Form
  option :procurement_amount, Types::DecimalField, optional: true
  option :special_requirements_choice, optional: true
  option :special_requirements, optional: true

  # @return [Hash] form params as request attributes
  def data
    super.except(:special_requirements_choice)
  end

  # Get the special requirements choice for the form based on stored values
  #
  # @return [String, nil]
  def special_requirements_choice
    return @special_requirements_choice if errors.any?

    if special_requirements == ""
      "no"
    elsif special_requirements.present?
      "yes"
    end
  end
end
