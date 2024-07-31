class Support::Organisation::Filtering
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :scoped_organisations, default: -> { Support::Organisation }
  attribute :local_authorities, default: -> { [] }
  attribute :phases, default: -> { [] }
  attribute :statuses, default: -> { [] }

  def results
    filtered_organisations = scoped_organisations

    filters.each_value { |filter| filtered_organisations = filter.filter(filtered_organisations) }

    filtered_organisations
  end

private

  def filters
    @filters ||=
      {
        local_authorities: Support::Concerns::ScopeFilter.new(local_authorities, scope: :by_local_authorities),
        phases: Support::Concerns::ScopeFilter.new(phases, scope: :by_phases, mapping: { "middle" => %w[middle_primary middle_secondary] }),
        statuses: Support::Concerns::ScopeFilter.new(statuses, scope: :by_statuses),
      }
  end
end
