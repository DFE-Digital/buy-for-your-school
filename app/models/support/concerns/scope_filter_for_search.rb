class Support::Concerns::ScopeFilterForSearch
  def initialize(value, exact_match: false)
    @value = value
    @exact_match = exact_match
  end

  def filter(records)
    return records unless entered?

    records.send(:by_search_term, value, exact_match:)
  end

  def entered?
    value.present?
  end

private

  attr_reader :value, :exact_match
end
