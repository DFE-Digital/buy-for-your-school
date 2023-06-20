module Support
  class EstablishmentGroupsController < ApplicationController
    skip_before_action :authenticate_user!
    skip_before_action :authorize_agent!
    skip_before_action :redirect_non_internal_users!

    def index
      query = <<-SQL
        ukprn LIKE :q OR
        uid LIKE :q OR
        lower(name) LIKE lower(:q)
      SQL

      respond_to do |format|
        format.json do
          render json: EstablishmentGroup
            .where(query, q: "%#{params.fetch(:q)}%")
            .limit(50)
            .each { |g| g.ukprn = "N/A" if g.ukprn.nil? }
            .as_json(only: %i[id uid name ukprn], methods: %i[formatted_name])
        end
      end
    end
  end
end
