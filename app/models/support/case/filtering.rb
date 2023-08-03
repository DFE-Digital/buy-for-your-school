class Support::Case::Filtering
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :scoped_cases, default: -> { Support::Case }
  attribute :category, default: -> { [] }
  attribute :state, default: -> { [] }
  attribute :agent, default: -> { [] }
  attribute :tower, default: -> { [] }
  attribute :level, default: -> { [] }
  attribute :has_org, default: -> { "" }
  attribute :search_term, default: -> { "" }
  attribute :procurement_stage, default: -> { [] }
  attribute :sort_by
  attribute :sort_order

  validates :search_term,
            presence: true,
            length: { minimum: 2, message: "Search term must be at least 2 characters" },
            on: :searching

  def results
    filtered_cases = scoped_cases

    filters.each_value { |filter| filtered_cases = filter.filter(filtered_cases) }

    filtered_cases = filtered_cases.not_closed unless closed_state_selected_or_search_term_entered?
    filtered_cases.sorted_by(sorting_criteria)
  end

private

  def closed_state_selected_or_search_term_entered?
    filters[:state].selected?(:closed) || filters[:search_term].entered?
  end

  def filters
    @filters ||=
      {
        state: Filter.new(state, scope: :by_state),
        category: Filter.new(category, scope: :by_category),
        agent: Filter.new(agent, scope: :by_agent),
        tower: Filter.new(tower, scope: :by_tower),
        level: Filter.new(level, scope: :by_level),
        procurement_stage: Filter.new(procurement_stage, scope: :by_procurement_stage),
        has_org: Filter.new(has_org, scope: :by_has_org, multiple: false),
        search_term: Filter.new(search_term, scope: :by_search_term, multiple: false),
      }
  end

  def sorting_criteria
    { sort_by:, sort_order: }
  end
end
