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

      respond_to do |format|
        format.json do
          render json: Organisation
            .where(query, q: "%#{params.fetch(:q)}%")
            .limit(25)
            .as_json(only: %i[id urn name], methods: %i[postcode formatted_name])
        end
      end
    end
  end
end
