class RequestForm < Form
  option :procurement_choice, optional: true
  option :procurement_amount, optional: true
  option :confidence_level, optional: true
  option :special_requirements_choice, optional: true
  option :special_requirements, optional: true
  option :about_procurement, optional: true

  # @return [Array<String>] very_confident, confident, slightly_confident, somewhat_confident, not_at_all_confident, not_applicable
  def confidence_levels
    @confidence_levels ||= Request.confidence_levels.keys.reverse
  end

  # @return [Hash] form params as request attributes
  def data
    super.except(:procurement_choice, :special_requirements_choice).merge(**data_values)
  end

  # Return whether the request is about a procurement
  # based on procurement_choice or persisted value
  #
  # @return [Boolean]
  def about_procurement?
    return procurement_choice != "not_about_procurement" if procurement_choice.present?

    about_procurement
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

private

  # Adjusted values for persisting in the database
  #
  # @return [Hash]
  def data_values
    values = {}
    values[:procurement_amount] = about_procurement? ? procurement_amount : nil unless @procurement_amount == Dry::Initializer::UNDEFINED
    values[:confidence_level] = about_procurement? ? confidence_level : nil unless @confidence_level == Dry::Initializer::UNDEFINED
    values[:about_procurement] = about_procurement? unless @procurement_choice == Dry::Initializer::UNDEFINED

    values
  end
end
