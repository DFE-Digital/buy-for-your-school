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
    super.except(:procurement_choice, :special_requirements_choice).merge(**normalised_data_values)
  end

  # Get the procurement choice for the form based on stored values
  #
  # @return [String, nil]
  def procurement_choice
    if about_procurement == false || @procurement_choice == "not_about_procurement"
      "not_about_procurement"
    elsif @procurement_amount == Dry::Initializer::UNDEFINED
      nil
    elsif @procurement_amount.blank?
      "no"
    else
      "yes"
    end
  end

  # Get the special requirements choice for the form based on stored values
  #
  # @return [String, nil]
  def special_requirements_choice
    if @special_requirements == Dry::Initializer::UNDEFINED
      nil
    elsif @special_requirements.blank?
      "no"
    else
      "yes"
    end
  end

  def about_procurement?
    procurement_choice != "not_about_procurement"
  end

private

  # Adjusted values for persisting in the database
  #
  # @return [Hash]
  def normalised_data_values
    # byebug
    values = {}
    values[:procurement_amount] = procurement_amount_normalised if procurement_amount.present?
    values[:special_requirements] = special_requirements_normalised
    values[:confidence_level] = about_procurement? ? @confidence_level : nil
    values[:about_procurement] = about_procurement_normalised

    values
  end

  # Get the procurement amount based on the choice
  #
  # @return [String, nil]
  def procurement_amount_normalised
    procurement_amount unless @procurement_choice == "no" || @procurement_choice == "not_about_procurement"
  end

  # Get the special requirements based on the choice
  #
  # @return [String, nil]
  def special_requirements_normalised
    # byebug
    special_requirements unless @special_requirements_choice == "no"
  end

  # Is the request about a procurement -- based on the procurement_choice value
  #
  # @return [String, nil]
  def about_procurement_normalised
    @procurement_choice != "not_about_procurement"
  end
end
