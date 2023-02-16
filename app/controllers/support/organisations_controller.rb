module Support
  class OrganisationsController < ApplicationController
    skip_before_action :authenticate_user!
    skip_before_action :authenticate_agent!, raise: false

    def index
      query = <<-SQL
        urn LIKE :q OR
        lower(name) LIKE lower(:q) OR
        lower(address->>'postcode') LIKE lower(:q)
      SQL

      results = Organisation
        .includes([:establishment_type])
        .where(query, q: "%#{params.fetch(:q)}%")
        .limit(50)

      respond_to do |format|
        format.json do
          render json: results.as_json(
            only: %i[id urn name ukprn],
            methods: %i[postcode formatted_name org_type],
          )
        end
      end
    end
  end
end
