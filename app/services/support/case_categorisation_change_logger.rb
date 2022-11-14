module Support
  class CaseCategorisationChangeLogger
    attr_reader :support_case, :changes, :agent_id

    def initialize(support_case:, agent_id:)
      @support_case = support_case
      @changes      = support_case.previous_changes
      @agent_id     = agent_id
    end

    def log!
      if changes.key?(:category_id) && changes.key?(:query_id)
        log_change_of_category_and_query
      elsif changes.key?(:category_id)
        log_change_of_category
      elsif changes.key?(:query_id)
        log_change_of_query
      end
    end

    def log_change_of_category
      from, to = changes[:category_id]
      log_categorisation_change(from:, to:, type: :category)
    end

    def log_change_of_query
      from, to = changes[:query_id]
      log_categorisation_change(from:, to:, type: :query)
    end

    def log_change_of_category_and_query
      category_from, category_to = changes[:category_id]
      query_from, query_to       = changes[:query_id]

      if category_from.present? && category_to.nil? && query_to.present?
        log_categorisation_change(from: category_from, to: query_to, type: :category_to_query)
      elsif query_from.present? && query_to.nil? && category_to.present?
        log_categorisation_change(from: query_from, to: category_to, type: :query_to_category)
      end
    end

  private

    def log_categorisation_change(from:, to:, type:)
      support_case.log_categorisation_change(from:, to:, type:)
    end
  end
end
