module MicrosoftGraph::Client
  module Queryable
  private

    def format_query(query_parts)
      query_parts.any? ? "?".concat(query_parts.join("&")) : ""
    end
  end
end
