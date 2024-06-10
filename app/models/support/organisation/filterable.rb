module Support::Organisation::Filterable
  extend ActiveSupport::Concern

  included do
    scope :by_local_authorities, ->(local_authority_codes) { joins(:local_authority).where("la_code IN(?)", local_authority_codes) }
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
