module Support::Organisation::Filterable
  extend ActiveSupport::Concern

  included do
    scope :by_local_authorities, ->(local_authorities) { where("local_authority->>'code' IN(?)", local_authorities) }

    scope :by_phases, ->(phases) { where(phase: phases) }
  end

  class_methods do
    def filtering(params = {})
      Support::Organisation::Filtering.new(scoped_organisations: all, **params)
    end

    def filtered_by(params)
      filtering(params).results
    end
  end
end
