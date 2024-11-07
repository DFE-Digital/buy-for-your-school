module Support
  class EstablishmentSearch < ApplicationRecord
    include Presentable

    enum :organisation_status, Organisation.statuses, prefix: :organisation

    scope :omnisearch, lambda { |query|
      sql = <<-SQL
        urn LIKE :q OR
        ukprn LIKE :q OR
        code LIKE :q OR
        lower(name) LIKE lower(:q) OR
        lower(postcode) LIKE lower(:q)
      SQL

      where(sql, q: "#{query}%").limit(30)
    }

    def self.find_record(organisation_id, organisation_type)
      return unless organisation_type.present? \
        && organisation_id.present? \
        && organisation_type.safe_constantize.present?

      organisation_type.safe_constantize.find(organisation_id)
    end
  end
end
