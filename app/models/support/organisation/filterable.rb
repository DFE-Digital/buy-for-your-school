module Support::Organisation::Filterable
  extend ActiveSupport::Concern

  included do
    scope :by_local_authorities, ->(local_authority_codes) { joins(:local_authority).where("la_code IN(?)", local_authority_codes) }
    scope :by_phases, ->(phases) { where(phase: phases) }
    scope :by_statuses, ->(statuses) { where(status: statuses) }
    scope :local_authority_maintained, -> { joins(:establishment_type).where(establishment_type: { code: [4, 1, 5, 15, 14, 2, 3, 5, 7, 12] }) }
    scope :not_local_authority_maintained, -> { joins(:establishment_type).where(establishment_type: { code: [10, 42, 43, 34, 44, 33, 28, 11, 35, 38, 36, 41, 40] }) }
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
