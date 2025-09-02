class Support::Concerns::ScopeFilterForSearch
  def initialize(value, exact_match: false)
    @value = value
    @exact_match = exact_match
  end

  def filter(records)
    return records unless entered?

    results = records.send(:by_search_term, value, exact_match:)

    return results if results.present?

    records.send(:by_mpan_or_mprn, value)
  end

  def entered?
    value.present?
  end

private

  attr_reader :value, :exact_match
end
