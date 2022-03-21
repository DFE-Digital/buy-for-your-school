# Edit a new self-serve journey (specification)

class EditJourneyForm < Form
  # @!attribute [r] name
  #   @return [String]
  option :name, optional: true

  # @return [Hash] form data to be persisted as request attributes
  def data
    to_h
      .except(:messages, :step)
      .compact
  end
end
